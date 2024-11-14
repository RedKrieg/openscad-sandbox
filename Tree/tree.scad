$fs = 0.1;
$fa = 1.0;

base_width = 5.0;
base_length = 50;
thickness = 1.6;
branch_angle = 26.0;
scale_factor = 0.75;
branch_depth = 6;
clearance = 0.2;

trunk_radius = 10.0;
branches_per_ring = 7;
ring_spacer_height = 10.0;
trunk_radius_modifier = thickness;

star_radius = 10.0;

smallest_branch = thickness/2;
nub_size = thickness;

module leaf(depth, length, width, angle) {
    thickness_scaler = depth / branch_depth;
    current_thickness = thickness * thickness_scaler;
    if (current_thickness >= smallest_branch) {
        linear_extrude(current_thickness) hull() {
            circle(d=width);
            translate([length - width, 0, 0]) circle(d=smallest_branch/2);
        }
    }
    if (depth > 0) {
        length_unit = length / (depth + 1);
        for (i=[1:depth]) {
            local_scale_factor = scale_factor * (depth - i + 1) / (depth + 1);
            if (width * local_scale_factor > smallest_branch) {
                translate([length_unit * i, 0, 0]) rotate([0, 0, angle]) leaf(depth - 1, length*local_scale_factor, width*local_scale_factor, angle*scale_factor);
                translate([length_unit * i, 0, 0]) rotate([0, 0, -angle]) leaf(depth - 1, length*local_scale_factor, width*local_scale_factor, angle*scale_factor);
            }
        }
    }
}

module branch(depth, length, width, angle) {
    translate([0, 0, -thickness/2]) union() {
        leaf(depth, length, width, angle);
        hull() {
            translate([0, width/2, thickness/2]) sphere(d=nub_size);
            translate([0, -width/2, thickness/2]) sphere(d=nub_size);
        }
    }
}

module bracket(width) {
    r = width/2;
    h = thickness/2;
    cup_radius = sqrt(r*r+h*h)+clearance;
    cube_size = cup_radius * 2;
    mouth_gap = width+clearance;
    difference() {
        //outer profile
        sphere(cup_radius+nub_size);
        // inner profile
        sphere(cup_radius);
        //nub cutouts
        translate([0, width/2, 0]) sphere(d=nub_size+clearance);
        translate([0, -width/2, 0]) sphere(d=nub_size+clearance);
        // shave top and bottom
        translate([-cube_size, -cube_size, thickness/2]) cube(cube_size*2);
        mirror([0, 0, 1]) translate([-cube_size, -cube_size, thickness/2]) cube(cube_size*2);
        //cut out middle
        translate([0, -mouth_gap/2, -thickness/2]) cube([mouth_gap, mouth_gap, thickness]);
    }
}

module trunk_cylinder(radius) {
    difference() {
        union() {
            cylinder(h=thickness, r=radius);
            translate([0, 0, thickness]) cylinder(h=ring_spacer_height, r1=radius, r2=radius-thickness-trunk_radius_modifier);
            translate([0, 0, thickness+ring_spacer_height]) cylinder(h=thickness, r=radius-thickness-trunk_radius_modifier);
        }
        cylinder(h=thickness, r=radius-thickness+clearance/2);
        translate([0, 0, thickness]) cylinder(h=ring_spacer_height, r1=radius-thickness+clearance/2, r2=radius-thickness*2-trunk_radius_modifier+clearance/2);
        translate([0, 0, thickness+ring_spacer_height]) cylinder(h=thickness, r=radius-thickness*2-trunk_radius_modifier+clearance/2);
    }
}

module trunk_ring(radius, width, length) {
    color("brown") trunk_cylinder(radius);
    r = width/2;
    h = thickness/2;
    cup_radius = sqrt(r*r+h*h)+clearance;
    for (angle=[0:360/branches_per_ring:359.9]) {
        rotate([0, 0, angle]) translate([radius + cup_radius + clearance/2, 0, thickness/2]) {
            color("green") branch(branch_depth, length, width, branch_angle);
            color("brown") bracket(base_width);
        }
    }
}

module round_off(r) {
   offset(r = r) {
     offset(delta = -r) {
       children();
     }
   }
}

module star() {
    star_points = [
        for (angle=[0:36:359]) [
            star_radius * (angle % 72 == 0 ? 1.0 : 0.5) * cos(angle),
            star_radius * (angle % 72 == 0 ? 1.0 : 0.5) * sin(angle)
        ]
    ];
    translate([0, 0, ring_spacer_height+thickness]) rotate([0, -90, 0]) union() {
        linear_extrude(height = star_radius/4, scale = 0.0) round_off(thickness/4) polygon(star_points);
        mirror([0, 0, 1]) linear_extrude(height = star_radius/4, scale = 0.0) round_off(thickness/4) polygon(star_points);
    }
    trunk_cylinder(trunk_radius-trunk_radius_modifier*4);
}

//rings
for (radius=[trunk_radius:-trunk_radius_modifier:base_width]) {
    translate([radius*base_length*1.5, 0, 0]) trunk_ring(radius, base_width, radius*5);
}
//base
color("red") translate([300, 0, 0]) union() {
    cylinder(h=thickness, r=trunk_radius*3);
    translate([0, 0, thickness]) cylinder(h=ring_spacer_height*4, r1=trunk_radius*3, r2=trunk_radius-thickness);
    translate([0, 0, thickness+ring_spacer_height*4]) cylinder(h=thickness, r=trunk_radius-thickness);
}
color("gold") translate([200, 0, 0]) star();
translate([150, 0, 0]) trunk_cylinder(trunk_radius-trunk_radius_modifier*4);