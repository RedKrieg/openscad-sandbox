$fs = 0.2;
$fa = 0.4;

total_height = 150;
top_radius = 75;
draft_angle = 35;
overhang_angle = 50;
rounding = 1.8;
spout_scaler = 1.45;

clearance = 0.2;

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

module inner_pot() {
    difference() {
        //outer profile
        union() {
            //basic shell
            translate([0, 0, total_height/4+rounding*2]) outer_solid(top_radius-rounding*2-clearance, total_height*3/4, rounding, draft_angle);
            //lip
            translate([0, 0, total_height]) hull() toroid(top_radius+rounding/2*cos(draft_angle), rounding);
            //base cone
            translate([0, 0, rounding*2]) outer_solid(top_radius*cos(draft_angle)-clearance-rounding*1.625, total_height/4+rounding*2, rounding, overhang_angle);
        }
        //inner profile
        translate([0, 0, total_height/4+rounding*4]) outer_solid(top_radius-rounding*4-clearance, total_height*3/4-rounding*2, rounding, draft_angle);
        translate([0, 0, rounding*4]) outer_solid(top_radius*cos(draft_angle)-clearance-rounding*3.25, total_height/4+rounding*2, rounding, overhang_angle);
        for(r=[15:15:360]) translate([0, 0, rounding*5]) rotate([0, 0, r]) rotate([0, 90, 0]) cylinder(h=top_radius, r=rounding);
    }
}

inner_pot();
outer_pot();