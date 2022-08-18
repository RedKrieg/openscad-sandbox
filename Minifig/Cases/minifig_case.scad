// geodesic sphere from https://www.thingiverse.com/thing:1484333
use <geodesic_sphere.scad>;

size = "medium"; //[tiny,small,medium,large,huge,gargantuan]
medium_radius = 12.5;
token_radius = str(size) == str("tiny") ? medium_radius/2 : (str(size) == str("large") ? medium_radius*2 : (str(size) == str("huge") ? medium_radius*3 : (str(size) == str("gargantuan") ? medium_radius*4 : medium_radius)));
token_height = 2;
token_buffer = 0.2;
wall_thickness = 1.2;

tokens_per_row = 12;
tokens_per_column = 1;

hinge_radius = 2;
hinge_eyelets = 5;
hinge_buffer = 0.4;

$fn=$preview ? 24:72;

get_x = function(x_index) wall_thickness*2+(token_height+token_buffer*2+wall_thickness)*x_index;
get_y = function(y_index) wall_thickness*2+token_radius+token_buffer+((token_radius+token_buffer)*2+wall_thickness)*y_index;
get_z = function() token_radius+token_buffer+wall_thickness;

module rounded_cube(length, width, height, radius, fn) {
    $fn=fn;
    hull() {
        for (l=[0+radius,length-radius], w=[0+radius,width-radius], h=[0+radius,height-radius]) {
            translate([l, w, h]) geodesic_sphere(radius);
        }
    }
}

module base(length, width, height) {
    difference() {
        rounded_cube(length, width, height, wall_thickness, 12);
        translate([0, 0, height-wall_thickness]) cube([length, width, wall_thickness]);
        translate([wall_thickness, wall_thickness, 3*token_radius/4]) cube([length-wall_thickness*2, width-wall_thickness*2, token_radius]);
        //token cutouts
        for(x=[0:tokens_per_row-1], y=[0:tokens_per_column-1]) {
            translate([get_x(x),get_y(y),get_z()]) rotate([0, 90, 0]) cylinder(h=token_height+token_buffer*2, r=token_radius+token_buffer);
        }
        //finger cutouts
        for(y=[0:tokens_per_column-1]) {
            translate([0, get_y(y), get_z()]) rotate([0, 90, 0]) cylinder(h=length, r=2*token_radius/3);
        }
    }
}

length = (wall_thickness + token_height + token_buffer * 2) * tokens_per_row + wall_thickness * 3;
width = (wall_thickness + (token_radius + token_buffer) * 2) * tokens_per_column + wall_thickness * 3;
//we add double wall thickness here because we're going to cut the top of the rounded cube flat (inner surface of the box)
height = token_radius + wall_thickness * 2 + token_buffer;
eyelet_length = (length-wall_thickness*2-hinge_buffer)/hinge_eyelets;
clip_radius = wall_thickness*0.5;
clip_buffer = token_buffer;

module eyelet(h, inner_radius, outer_radius) {
    rotate([0, 90, 0]) difference() {
        cylinder(h=h, r=outer_radius);
        cylinder(h=h, r=inner_radius);
    }
}

module solid_eyelet(inner_radius) {
    height = eyelet_length-hinge_buffer;
    outer_radius = wall_thickness+hinge_radius+hinge_buffer;
    union() {
        eyelet(height, inner_radius, outer_radius);
        rotate([0, 90, 0]) linear_extrude(height) polygon([
            [outer_radius/sqrt(2), -outer_radius/sqrt(2)],
            [outer_radius*2, outer_radius],
            [0, outer_radius],
            [outer_radius-hinge_buffer, 0]
        ]);
    }
}

module cutout_eyelet() {
    eyelet(eyelet_length+hinge_buffer, hinge_buffer, wall_thickness+hinge_radius+hinge_buffer*2);
}

module boxes(length, width, height) {
    inner_radius = hinge_radius+hinge_buffer;
    difference() {
        union() {
            base(length, width, height);
            for(x=[1:2:hinge_eyelets-1]) {
                translate([wall_thickness+x*eyelet_length+hinge_buffer, width+hinge_radius+hinge_buffer, height-wall_thickness]) mirror([0, 1, 0]) solid_eyelet(inner_radius);
            }
        }
        for(x=[0:2:hinge_eyelets-1]) {
            translate([wall_thickness+x*eyelet_length, width+hinge_radius+hinge_buffer, height-wall_thickness]) cutout_eyelet();
        }
    }
    difference() {
        union() {
            translate([0, width+hinge_radius*2+hinge_buffer*2, 0]) base(length, width, height);
            for(x=[0:2:hinge_eyelets-1]) {
                translate([wall_thickness+x*eyelet_length+hinge_buffer, width+hinge_radius+hinge_buffer, height-wall_thickness]) solid_eyelet(hinge_buffer);
            }
        }
        for(x=[1:2:hinge_eyelets-1]) {
            translate([wall_thickness+x*eyelet_length, width+hinge_radius+hinge_buffer, height-wall_thickness]) cutout_eyelet();
        }
    }
}

module clip() {
    translate([length/2, width*2+hinge_radius*2+hinge_buffer*2, height-wall_thickness]) rotate([0, -90, 0]) linear_extrude(eyelet_length, center=true) {
        polygon([
            [-wall_thickness*2, 0],
            [-wall_thickness, wall_thickness],
            [clip_radius*3, wall_thickness],
            [clip_radius*3, 0]
        ]);
        translate([clip_radius*2, clip_buffer]) circle(clip_radius);
    }
}

module clip_groove() {
    translate([(length-eyelet_length)/2-clip_buffer, 0, height-clip_radius*2-wall_thickness]) rotate([0, 90, 0]) cylinder(h=eyelet_length+clip_buffer*2, r=clip_radius);
}

module hinged_box() {
    union() {
        boxes(length, width, height);
        translate([wall_thickness+hinge_buffer, width+hinge_radius+hinge_buffer, height-wall_thickness]) rotate([0, 90, 0]) cylinder(h=eyelet_length*hinge_eyelets-hinge_buffer, r=hinge_radius);
    }
}

module full_assembly() {
    difference() {
        hinged_box();
        clip_groove();
    }
    clip();
}

full_assembly();