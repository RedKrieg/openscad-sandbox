$fn = 101;

base_thickness = 2;
cup_radius = 15;
cup_depth = 2.5;
support_thickness = 2;

rock_points = [
    [0, 0, 10],
    [25, 50, 12],
    [-20, 30, 8]
];

// radius of the small sphere to cut a dimple
//   args: dimple_radius, dimple_depth
function small_radius(dr, dd) = (dr * dr + dd * dd) / (2 * dd);

module pits(base_thickness, wall_thickness, radius) {
    // both of these have to be wrong for my physical measurements to make sense
    x_spacing = radius + wall_thickness + radius * cos(60);
    y_spacing = 2 * radius * sin(60) + wall_thickness;
    linear_extrude(height=base_thickness) {
        for (x=[-10:10], y=[-10:10]) {
            translate([x*x_spacing, y*y_spacing + abs(x%2)*y_spacing/2]) circle(r=radius, $fn=6);
        }
    }
}

module hex_cylinder(h, r, wall_thickness) {
    internal_radius = r - wall_thickness;
    hex_radius = internal_radius / 4;
    x_spacing = hex_radius + wall_thickness + hex_radius * cos(60);
    y_spacing = 2 * hex_radius * sin(60) + wall_thickness / 2;
    circumference = 2 * internal_radius * PI;
    hex_count = floor(circumference / x_spacing);
    theta = 360 / hex_count;
    difference() {
        cylinder(h=h, r=r);
        cylinder(h=h, r=r-support_thickness);
        for (t=[0:theta:360], z=[0:1:h/y_spacing+y_spacing]) {
            translate([0, 0, z*y_spacing]) rotate([0, -90, t+(theta*abs(z%2)/2)]) cylinder(r=r / 4, h=r+wall_thickness, $fn=6);
        }
    }
}

// TODO: modularize
difference() {
    union() {
        difference() {
            hull() for (point = rock_points) translate([point[0], point[1], 0]) cylinder(h=base_thickness, r1=cup_radius+support_thickness, r2=cup_radius);
            hull() for (point = rock_points) translate([point[0], point[1], 0]) cylinder(h=base_thickness, r1=cup_radius-support_thickness, r2=cup_radius-support_thickness);
        }
        difference() {
            hull() for (point = rock_points) translate([point[0], point[1], 0]) cylinder(h=base_thickness, r=cup_radius-support_thickness);
            pits(base_thickness, support_thickness, cup_radius/4);
        }
        for (point = rock_points) {
            difference() {
                translate([point[0], point[1], 0]) union() {
                    cylinder(h=base_thickness, r=cup_radius);
                    translate([0, 0, base_thickness]) hex_cylinder(h=point[2], r=cup_radius, wall_thickness=support_thickness);
                    translate([0, 0, base_thickness + point[2] - support_thickness]) cylinder(h=cup_depth + support_thickness, r=cup_radius);
                }
                dx = point[2] + base_thickness;
                sr = small_radius(cup_radius - support_thickness, cup_depth);
                sd = dx + sr - point[2];
                translate(point + [0, 0, sd]) sphere(r=sr);
            }
        }
    }
}