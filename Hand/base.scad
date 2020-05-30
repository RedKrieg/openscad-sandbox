use <scad-utils/morphology.scad>
use <ball_joint.scad>

$fn = 101;
sides = 6;
lower_radius = 90;
upper_radius = 85;
ball_radius = 5.5;  //base of ball

module rounded_edge(radius, height) {
    scale([1, 1, height / (radius + height)]) minkowski() {
        children();
        difference() {
            sphere(radius);
            translate([-radius, -radius, -2 * radius]) cube(radius*2);
        }
    }
}

// a series of hexagons on a grid to be removed from the base
module pits(base_thickness, wall_thickness, radius) {
    y_spacing = 2 * radius * sin(60) + wall_thickness;
    x_spacing = y_spacing * cos(30);
    linear_extrude(height=base_thickness) {
        for (x=[-20:20], y=[-20:20]) {
            translate([x*x_spacing, y*y_spacing + abs(x%2)*y_spacing/2]) circle(r=radius, $fn=6);
        }
    }
}

module base(sides, lower_radius, upper_radius, ball_radius) {
    theta = 360/sides;
    fn = $fn;
    rise = lower_radius-upper_radius;
    rotate_extrude($fn=sides) {
        translate([upper_radius, 0], $fn=fn) difference() {
            circle(r=rise);
            translate([-rise, 0]) square(rise);
            translate([-rise, -rise*2]) square(rise*2);
        }
        square([upper_radius, rise]);
    }
    for (i=[0:theta:360-theta]) {
        rotate([0, 0, i]) translate([upper_radius - ball_radius, 0, rise]) socket();
    }
}

module inner_base(sides, radius, height, socket_base_radius) {
    theta = 360/sides;
    hull() {
        for (i=[0:theta:360-theta]) {
            rotate([0, 0, i]) translate([radius - socket_base_radius, 0, 0]) cylinder(h=height, r=socket_base_radius);
        }
    }
}

module newbase(sides, radius, height, socket_base_radius, edge_radius) {
    theta = 360/sides;
    difference() {
        inner_base(sides, radius, height, socket_base_radius);
        pits(height, height, edge_radius*2);
    }
    difference() {
        rounded_edge(edge_radius, height) inner_base(sides, radius, height, socket_base_radius);
        inner_base(sides, radius, height, socket_base_radius);
    }
    for (i=[0:theta:360-theta]) {
        rotate([0, 0, i]) translate([radius - socket_base_radius, 0, 0]) cylinder(h=height, r=socket_base_radius);
        rotate([0, 0, i]) translate([radius - socket_base_radius, 0, height]) socket();
    }
}
newbase(sides, 90, 3, 4.35, 3);

//base(sides, lower_radius, upper_radius, ball_radius);