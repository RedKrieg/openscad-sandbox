// Which object should be rendered
render_target = "base"; // [base, ring, star, all]
// When rendering rings, which ring
ring_number = 0; // [0:6]

// Width of the branches at the hinge location
base_width = 5.0;
// Branch thickness
thickness = 1.6;
// Base branch angle
branch_angle = 25.0;
// Shrink needle by this amount per iteration
scale_factor = 0.75;
// Number of branches to attempt
branch_depth = 6;
// Clearance, used in various places
clearance = 0.2;

// Outer radius of ring 0
trunk_radius = 15.0;
// Number of branches to place per ring
branches_per_ring = 7;
// Vertical space between rings
ring_spacer_height = 10.0;
// Amount to shrink trunk radius by per ring
trunk_radius_modifier = thickness;
// Radius of star topper
star_radius = 15.25;

// Features down to 0.1mm, angular size at least 1.0 degrees
$fs = 0.1;
$fa = 1.0;

// Don't let branches be less than half the thickness value
smallest_branch = thickness/2;
// Nubs should be the same size as the branch
nub_size = thickness;

module leaf(depth, length, width, angle) {
    // scale down thickness more the deeper we go
    thickness_scaler = depth / branch_depth;
    current_thickness = thickness * thickness_scaler;
    // trim branches thinner than half the thickness
    if (current_thickness >= smallest_branch) {
        // create needle
        linear_extrude(current_thickness) hull() {
            circle(d=width);
            // width here is always small to form a point
            translate([length - width, 0, 0]) circle(d=smallest_branch/2);
        }
    }
    // create leaves
    if (depth > 0) {
        // divide length in to unit nodes based on current depth
        length_unit = length / (depth + 1);
        // hit every node on this branch
        for (i=[1:depth]) {
            // smaller branches near the end
            local_scale_factor = scale_factor * (depth - i + 1) / (depth + 1);
            // make sure we need to render them at all before we go doing all that work
            if (width * local_scale_factor > smallest_branch) {
                // random offset in degrees, up to depth (more variation toward the end)
                angles = rands(-i, i, 2);
                // branch positive
                translate([length_unit * i, 0, 0]) rotate([0, 0, angles[0]+angle]) leaf(depth - 1, length*local_scale_factor, width*local_scale_factor, angle*scale_factor);
                // branch negative
                translate([length_unit * i, 0, 0]) rotate([0, 0, angles[1]-angle]) leaf(depth - 1, length*local_scale_factor, width*local_scale_factor, angle*scale_factor);
            }
        }
    }
}

module branch(depth, length, width, angle) {
    // shift down half the thickness since it'll be easier to work with later centered around the z axis
    translate([0, 0, -thickness/2]) union() {
        // render leaves
        leaf(depth, length, width, angle);
        //nubs for hinge
        hull() {
            translate([0, width/2, thickness/2]) sphere(d=nub_size);
            translate([0, -width/2, thickness/2]) sphere(d=nub_size);
        }
    }
}

// this is just a sphere shell with the top bottom and middle cut out
module bracket(width) {
    r = width/2;
    h = thickness/2;
    // calculate the size of the sphere that the branch will inscribe (plus clearance)
    cup_radius = sqrt(r*r+h*h)+clearance;
    cube_size = cup_radius * 2;
    mouth_gap = width+clearance;
    difference() {
        //outer profile
        sphere(cup_radius+nub_size);
        // inner profile
        sphere(cup_radius);
        // nub cutouts
        translate([0, width/2, 0]) sphere(d=nub_size+clearance);
        translate([0, -width/2, 0]) sphere(d=nub_size+clearance);
        // shave top and bottom
        translate([-cube_size, -cube_size, thickness/2]) cube(cube_size*2);
        mirror([0, 0, 1]) translate([-cube_size, -cube_size, thickness/2]) cube(cube_size*2);
        // cut out middle
        translate([0, -mouth_gap/2, -thickness/2]) cube([mouth_gap, mouth_gap, thickness]);
    }
}

// hollow stackable cones made from two discs and a tapered cylinder
module trunk_cylinder(radius) {
    difference() {
        // outer profile
        union() {
            cylinder(h=thickness, r=radius);
            translate([0, 0, thickness]) cylinder(h=ring_spacer_height, r1=radius, r2=radius-trunk_radius_modifier);
            translate([0, 0, thickness+ring_spacer_height]) cylinder(h=thickness, r=radius-thickness-trunk_radius_modifier);
        }
        // inner profile
        cylinder(h=thickness, r=radius-thickness+clearance/4);
        translate([0, 0, thickness]) cylinder(h=ring_spacer_height, r1=radius-thickness+clearance/4, r2=radius-thickness*2-trunk_radius_modifier+clearance/4);
        translate([0, 0, thickness+ring_spacer_height]) cylinder(h=thickness, r=radius-thickness*2-trunk_radius_modifier+clearance/4);
    }
}

// cylinder, brackets, and branches for a single layer of the tree
module trunk_ring(radius, width, length) {
    color("brown") trunk_cylinder(radius);
    r = width/2;
    h = thickness/2;
    cup_radius = sqrt(r*r+h*h)+clearance;
    // arrange brackets and branches around the trunk
    for (angle=[0:360/branches_per_ring:359.9]) {
        rotate([0, 0, angle]) translate([radius + cup_radius + clearance/2, 0, thickness/2]) {
            color("green") branch(branch_depth, length, width, branch_angle);
            color("brown") bracket(base_width);
        }
    }
}

// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Transformations#offset
module round_off(r) {
   offset(r = r) {
     offset(delta = -r) {
       children();
     }
   }
}

module star() {
    // 10 points, every other one is half the radius
    star_points = [
        for (angle=[0:36:359]) [
            star_radius * (angle % 72 == 0 ? 1.0 : 0.5) * cos(angle),
            star_radius * (angle % 72 == 0 ? 1.0 : 0.5) * sin(angle)
        ]
    ];
    //stand the star upright
    translate([0, 0, ring_spacer_height+thickness]) rotate([0, -90, 0]) union() {
        //move up half the thickness
        translate([0, 0, thickness/2])
            // extrude 1/4th of the radius to a point at the center
            linear_extrude(height = star_radius/4, scale = 0.0)
            // round points on the star
            round_off(thickness/2)
            // convert star points to a 2d drawing
            polygon(star_points);
        // extrude a flat copy of size thickness
        linear_extrude(height = thickness, center = true) round_off(thickness/2) polygon(star_points);
        // create a mirror of the first star along the z axis
        mirror([0, 0, 1]) translate([0, 0, thickness/2]) linear_extrude(height = star_radius/4, scale = 0.0) round_off(thickness/2) polygon(star_points);
    }
    // base for the star, 7 here depends on tree_radius but I haven't bothered calculating it, so 7 it is.
    trunk_cylinder(trunk_radius-trunk_radius_modifier*7);
}

// module used for maker's mark on the base copied from
// https://openhome.cc/eGossip/OpenSCAD/TextCircle.html
module revolve_text(radius, chars) {
    circumference = 2 * PI * radius;
    chars_len = len(chars);
    font_size = circumference / chars_len;
    step_angle = 360 / chars_len;
    for(i = [0 : chars_len - 1]) {
        rotate(-i * step_angle)
            translate([0, radius + font_size / 2, 0])
                text(
                    chars[i],
                    font = "Ubuntu:style=Bold",
                    size = font_size,
                    valign = "center", halign = "center"
                );
    }
}

// rings and cylinders with text on the bottom
module base() {
    difference() {
        union() {
            cylinder(h=thickness, r=trunk_radius*2);
            translate([0, 0, thickness]) cylinder(h=ring_spacer_height*5, r1=trunk_radius*2, r2=trunk_radius);
            translate([0, 0, thickness+ring_spacer_height*5]) cylinder(h=thickness, r=trunk_radius-thickness);
        }
        linear_extrude(clearance) mirror([1, 0, 0]) revolve_text(trunk_radius*2-10, "Design by RedKrieg  ");
    }
}

// render everything in one scene
module render_all() {
    //rings
    for (radius=[trunk_radius:-trunk_radius_modifier:base_width]) {
        translate([radius*100, 0, 0]) trunk_ring(radius, base_width, radius*5);
    }
    //base
    color("red") translate([300, 0, 0]) base();
    //star
    color("gold") translate([200, 0, 0]) star();
    //empty topper
    translate([150, 0, 0]) trunk_cylinder(trunk_radius-trunk_radius_modifier*7);
}

// rendering options
if (render_target == "all") {
    render_all();
} else if (render_target == "base") {
    color("red") base();
} else if (render_target == "ring") {
    radius = trunk_radius-trunk_radius_modifier*ring_number;
    trunk_ring(radius, base_width, radius*5);
} else if (render_target == "star") {
    color("gold") star();
}
