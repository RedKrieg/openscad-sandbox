$fs = 0.2;
$fa = 0.2;

total_height = 150;
top_radius = 75;
draft_angle = 35;
overhang_angle = 45;
rounding = 1.8;
spout_scaler = 1.5;

module outer_solid(radius, height, rounding, draft) {
    rotate_extrude() hull() {
        square([rounding, height]);
        translate([radius-rounding, height-rounding]) circle(rounding);
        translate([radius*cos(draft)-rounding, rounding]) circle(rounding);
    }
}

module toroid(lr, sr) {
    rotate_extrude() translate([lr-sr, sr]) circle(sr);
}

module outer_pot() {
    difference() {
        union() {
            outer_solid(top_radius, total_height, rounding, draft_angle); //basic shell
            linear_extrude(height = total_height/4, scale = spout_scaler) translate([top_radius*cos(draft_angle), 0]) circle(top_radius/4);
        }
        translate([0, 0, rounding*2]) outer_solid(top_radius-rounding*2, total_height, rounding, draft_angle);
        translate([0, 0, rounding*2]) linear_extrude(height = total_height/4-rounding*2, scale = spout_scaler) translate([top_radius*cos(draft_angle), 0]) circle(top_radius/4-rounding);
    }
    translate([top_radius*cos(draft_angle)*spout_scaler, 0, total_height/4-rounding]) difference() {
        toroid(top_radius/4*spout_scaler, rounding);
        mirror([0, 0, 1]) translate([0, 0, -rounding]) cylinder(h=total_height, r=top_radius);
    }
}

outer_pot();