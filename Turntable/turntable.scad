/*
    Segmented Turntable by RedKrieg (redkrieg@gmail.com)
    Opposing Cylinder Bearings idea from https://www.youtube.com/watch?v=EUoU_x8Me8Q
    
*/
$fs = 0.2;
$fa = 0.2;

render_target = "assembly"; //[assembly,lower_race,upper_race,bearing,bearings,clip,clips,center_pin,shim,shims]

outer_diameter = 490;
outer_rim_height = 12.5;
outer_rim_gap = 20;
support_height = 12;
surface_thickness = 1.6;
surface_gap = 1.8;
pin_diameter = 6;
pin_clearance = 0.1;

bearing_diameter = 15;
bearing_corner_radius = 1;
segments = 7;

cup_diameter=13;

race_profile_size = (bearing_diameter+surface_thickness*2)*sqrt(2);
race_cutout_size = bearing_diameter*sqrt(2);
inner_brace_height = race_cutout_size/2;
outer_r = outer_diameter / 2 + surface_thickness;
race_center = outer_r-race_profile_size-outer_rim_gap + pin_diameter - surface_thickness;
inner_hole_radius = race_center - race_profile_size + pin_diameter - surface_thickness;
optimal_bearing_count = floor(race_center*2*PI/bearing_diameter);
//this type of bearing requires an even bearing count
bearing_count = optimal_bearing_count - (optimal_bearing_count%2?1:0);
echo("Race Center: ", race_center);
echo("Bearing Count: ", bearing_count);
pin_offset_x = race_cutout_size/2+pin_clearance;
pin_offset_y = surface_thickness+inner_brace_height/2;

module lower_profile() {
    //base flat
    translate([inner_hole_radius, 0]) square([outer_r-inner_hole_radius, surface_thickness]);
    //outer rim
    translate([outer_r-surface_thickness, surface_thickness]) square([surface_thickness, outer_rim_height]);
    //inner_rim
    translate([inner_hole_radius, surface_thickness]) square([surface_thickness, inner_brace_height]);
    //middle_rim
    translate([outer_r-outer_rim_gap-surface_thickness, surface_thickness]) square([surface_thickness, inner_brace_height]);
    //race profile
    translate([race_center, 0]) polygon([[-race_profile_size/2, 0], [race_profile_size/2, 0], [0, race_profile_size/2]]);
    //support leg
    translate([race_center-surface_thickness, surface_thickness]) square([surface_thickness*2, support_height]);
}

module upper_profile() {
    //flat
    translate([pin_diameter/2, 0]) square([outer_r-pin_diameter/2+surface_thickness, surface_thickness]);
    //outer rim
    translate([outer_r+surface_thickness, surface_thickness]) square([surface_thickness, inner_brace_height+outer_rim_height+surface_thickness]);
    //outer chamfer
    hull() {
        translate([outer_r, 0]) square(surface_thickness);
        translate([outer_r+surface_thickness, surface_thickness]) square(surface_thickness);
    }
    //inner rim
    translate([pin_diameter/2, surface_thickness]) square([surface_thickness, inner_brace_height]);
    //bearing block
    hull() {
        for (x=[-race_profile_size/2+bearing_corner_radius, race_profile_size/2-bearing_corner_radius]) translate([race_center+x, surface_thickness+inner_brace_height-bearing_corner_radius]) circle(r=bearing_corner_radius);
        translate([race_center, bearing_corner_radius]) circle(r=bearing_corner_radius);
    }
    //hull() for (x=[-race_profile_size/2, race_profile_size/2])    translate([race_center+x-surface_thickness/2, surface_thickness]) square([surface_thickness, inner_brace_height]);
    //middle rim
    translate([race_center/2, surface_thickness]) square([surface_thickness, inner_brace_height]);
}

module race_cutout() {
    // slightly lower apex of the race to reduce friction in the bearing.
    translate([race_center, 0]) polygon([[-race_cutout_size/2, 0], [race_cutout_size/2, 0], [0, race_cutout_size/2-surface_gap/3]]);
}

module lower_rib() {
    difference() {
        translate([inner_hole_radius, 0, surface_thickness]) cube([outer_r-inner_hole_radius-outer_rim_gap, surface_thickness, inner_brace_height]);
        //holes
        for (x=[race_center-pin_offset_x, race_center+pin_offset_x])
            translate([x, 0, pin_offset_y]) rotate([90, 0, 0]) cylinder(h=surface_thickness*2, d=pin_diameter+pin_clearance/2, center=true);
    }
}

module lower_rib_middle() {
    translate([inner_hole_radius, 0, surface_thickness]) cube([outer_r-inner_hole_radius-outer_rim_gap, surface_thickness, inner_brace_height]);
}

module upper_rib_middle() {
    translate([race_center/2, 0, -inner_brace_height]) cube([outer_r-race_center/2+surface_thickness, surface_thickness, inner_brace_height]);
}

module upper_rib() {
    difference() {
        translate([pin_diameter/2, 0, -inner_brace_height]) cube([outer_r-pin_diameter/2+surface_thickness, surface_thickness, inner_brace_height]);
        //holes
        for (x=[
            race_center-pin_offset_x-pin_diameter,
            race_center+pin_offset_x+pin_diameter,
            race_center/2+pin_offset_x,
            race_center/4
        ])
            translate([x, 0, -pin_offset_y+surface_thickness]) rotate([90, 0, 0]) cylinder(h=surface_thickness*2, d=pin_diameter+pin_clearance/2, center=true);
    }
}

module leg_cutout() {
    hull() {
        translate([0, 0, surface_thickness+inner_brace_height]) linear_extrude(height=support_height-inner_brace_height/2, twist=-360/segments/2) translate([race_center-surface_thickness*2, -surface_thickness*4]) square(surface_thickness*4);
        translate([race_center-surface_thickness*2, -surface_thickness*4, surface_thickness+inner_brace_height+support_height]) cube(surface_thickness*8);
    }
}

module cup() {
    rotate_extrude() {
        hull() {
            square([cup_diameter/2+surface_thickness,surface_thickness]);
            translate([0,-cup_diameter/2]) square([surface_thickness,cup_diameter/2]);
        }
        translate([cup_diameter/2, surface_thickness]) square([surface_thickness, surface_thickness]);
    }
}

module lower_race() {
    difference() {
        union() {
            //surface
            rotate_extrude(angle=360/segments) difference() {
                lower_profile();
                race_cutout();
            }
            //ribs
            lower_rib();
            rotate([0, 0, 360/segments]) mirror([0, 1, 0]) lower_rib();
            rotate([0, 0, 360/segments/2]) union() {
                lower_rib_middle();
                mirror([0, 1, 0]) lower_rib_middle();
            }
            //foot
            rotate([0, 0, 360/segments/2]) union() {
                //outer brace
                translate([race_center+surface_thickness, surface_thickness, surface_thickness+inner_brace_height]) rotate([90, 0, 0]) linear_extrude(surface_thickness*2) polygon([[0,0],[race_center-inner_hole_radius-surface_thickness,0],[0,support_height-inner_brace_height]]);
                //inner brace
                translate([inner_hole_radius, surface_thickness, surface_thickness+inner_brace_height]) rotate([90, 0, 0]) linear_extrude(surface_thickness*2) polygon([[0,0],[race_center-inner_hole_radius-surface_thickness,0],[race_center-inner_hole_radius-surface_thickness,support_height-inner_brace_height]]);
                //cup
                translate([race_center, 0, inner_brace_height+surface_thickness]) cup();
            }
        }
        //we have to cut this twice because for some reason cutting it now without cutting it up top in 2d makes the surface non-manifold
        rotate_extrude() race_cutout();
        leg_cutout();
        rotate([0,0,360/segments]) mirror([0, 1, 0]) leg_cutout();
    }
}

module upper_race() {
    difference() {
        union() {
            rotate_extrude(angle=360/segments) difference() {
                translate([0, -inner_brace_height-surface_thickness]) upper_profile();
                mirror([0, 1]) race_cutout();
            }
            upper_rib();
            rotate([0, 0, 360/segments]) mirror([0, 1, 0]) upper_rib();
            rotate([0, 0, 360/segments/2]) union() {
                upper_rib_middle();
                mirror([0, 1, 0]) upper_rib_middle();
            }
        }
        rotate_extrude() mirror([0, 1]) race_cutout();
    }
}

module bearing() {
    hull() {
        for (y=[bearing_corner_radius, bearing_diameter-bearing_corner_radius]) rotate_extrude() {
            translate([bearing_diameter/2-bearing_corner_radius, y]) circle(bearing_corner_radius);
        }
    }
}

module bearings() {
    w = ceil(sqrt(bearing_count));
    s = (bearing_diameter+surface_thickness);
    for (x=[0:w-1], y=[0:w-1])
        if (x*w+y<bearing_count) translate([x*s, y*s, 0]) bearing();
}

module clip() {
    difference() {
        rotate([-90, 0, 0]) union() {
            // head
            cylinder(h=surface_thickness, r=inner_brace_height/2-surface_thickness/2);
            //shaft
            translate([0, 0, surface_thickness]) cylinder(h=surface_thickness*2+pin_clearance, d=pin_diameter);
            //hooks
            translate([0, 0, surface_thickness*3+pin_clearance]) cylinder(h=surface_thickness/2, d=pin_diameter+surface_thickness);
            translate([0, 0, surface_thickness*3+pin_clearance+surface_thickness/2]) cylinder(h=surface_thickness, d1=pin_diameter+surface_thickness, d2=pin_diameter-surface_thickness/2);
        }
        //flats
        for (i=[0,1])
            mirror([0, 0, i]) translate([0, pin_diameter, -pin_diameter*4/3]) cube(pin_diameter*2, center=true);
        //slot
        hull() {
            for (y=[surface_thickness*1.5, pin_diameter*2])
            translate([0, y, 0]) cylinder(h=pin_diameter*2, d=surface_thickness, center=true);
        }
    }
}

module clips() {
    c = 6*segments;
    w = ceil(sqrt(c));
    s = (pin_diameter*2+surface_thickness);
    for (x=[0:w-1], y=[0:w-1])
        if (x*w+y<c) translate([x*s, y*s, 0]) clip();
}

module center_pin() {
    translate([0, 0, -0.4]) cylinder(h=0.4, d=pin_diameter+surface_thickness);
    cylinder(h=surface_thickness+inner_brace_height, d=pin_diameter);
}

module shim() {
    h=pin_diameter*2/3;
    r=(surface_thickness)/2-pin_clearance;
    hull() {
        cylinder(h=h, r=r);
        translate([0, pin_diameter-r, 0]) cylinder(h=h, r=r);
    }
    hull()
        for (x=[-pin_diameter/3,pin_diameter/3])
        translate([x, 0, 0]) cylinder(h=h, r=r);
}

module shims() {
    c = 6*segments;
    w = ceil(sqrt(c));
    s = (pin_diameter*2+surface_thickness);
    for (x=[0:w-1], y=[0:w-1])
        if (x*w+y<c) translate([x*s, y*s, 0]) shim();
}

module assembly() {
    //main race parts
    lower_race();
    translate([0, 0, -surface_thickness]) upper_race();
    //the rest of the race
    for (i=[1:segments-1]) {
        #color("#ff0000") rotate([0, 0, i*360/segments]) lower_race();
        #color("#0000ff") rotate([0, 0, i*360/segments]) translate([0, 0, -surface_thickness]) upper_race();
    }
    for (i=[0:bearing_count-1])
    //bearings
    color("#00ff00") rotate([0, 0, i*360/bearing_count]) translate([race_center, 0, -surface_thickness/2]) rotate([0, i%2?45:-45, 0]) translate([0, 0, -bearing_diameter/2]) bearing();
    //clips
    translate([race_center-race_cutout_size/2, -surface_thickness*2, surface_thickness+inner_brace_height/2]) rotate([0, -45, 0]) clip();
    translate([race_center-race_cutout_size/2-pin_diameter, -surface_thickness*2, -inner_brace_height/2-surface_thickness]) rotate([0, -90, 0]) clip();
    translate([0, 0, -inner_brace_height-surface_thickness*2]) center_pin();
}

if (render_target=="assembly")
    assembly();
else if (render_target=="lower_race")
    lower_race();
else if (render_target=="upper_race")
    upper_race();
else if (render_target=="bearing")
    bearing();
else if (render_target=="bearings")
    bearings();
else if (render_target=="clip")
    clip();
else if (render_target=="clips")
    clips();
else if (render_target=="center_pin")
    center_pin();
else if (render_target=="shim")
    shim();
else if (render_target=="shims")
    shims();
else
    echo("ERROR: Invalid render target");