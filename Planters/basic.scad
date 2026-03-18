$fs = 0.2;
$fa = 0.2;

height = 150;
base_radius = 60;
top_radius = 75;
rounding = 1.8;

module base_corner() {
    translate([base_radius-rounding, rounding]) circle(rounding);
}

module top_edge() {
    translate([top_radius-rounding, height-rounding]) circle(rounding);
}

module pot_profile() {
    hull() {
        square(rounding*2);
        base_corner();
    }
    hull() {
        base_corner();
        top_edge();
    }
}

module inner_profile() {
    hull() {
        square(rounding*2);
        translate([-rounding*2, 0]) base_corner();
    }
    hull() {
        translate([-rounding*2, 0]) base_corner();
        translate([-rounding*2, 0]) top_edge();
    }
    hull() {
        translate([-rounding*2, 0]) top_edge();
        top_edge();
    }
}

rotate_extrude() pot_profile();
translate([0, 0, rounding*2]) rotate_extrude() inner_profile();