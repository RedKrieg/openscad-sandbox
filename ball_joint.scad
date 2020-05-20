use <scad-utils/morphology.scad>

$fn=101;

module socket_wall(diameter, wall_thickness, opening_angle) {
    r = diameter/2;
    //round to just under half of wall thickness to help the rounding module work
    rounding(r=wall_thickness*0.499) difference() {
        //ring
        circle(r=r);
        circle(r=r-wall_thickness);
        //opening
        rotate(90-opening_angle/2) square(r);
    }
}

module ball_wall(diameter, wall_thickness, base_cutoff_percent) {
    r = diameter/2;
    cutoff_movement = r - diameter*base_cutoff_percent;
    difference() {
        circle(r=r);
        circle(r=r-wall_thickness);
        //0.01 here eliminates a small artifact from a 0 width wall
        translate([-0.01, -r - cutoff_movement]) square(r);
    }
}

module socket_connector_wall(ball_diameter, tunnel_diameter, wall_thickness, stem_length) {
    br = ball_diameter/2;
    tr = tunnel_diameter/2;
    difference() {
        translate([tr, -br-stem_length]) square([wall_thickness, br+stem_length]);
        circle(r=br-wall_thickness/2);
    }
}

module ball_connector_wall(ball_diameter, tunnel_diameter, wall_thickness, stem_length) {
    br = ball_diameter/2;
    tr = tunnel_diameter/2;
    difference() {
        translate([tr, -br-stem_length]) square([wall_thickness, br+stem_length]);
        circle(r=br-wall_thickness);
    }
}

module flex_cut(ball_diameter, flex_depth_percent, flex_cut_percent) {
    br = ball_diameter/2;
    depth = br - ball_diameter * flex_depth_percent;
    cut_width = br*flex_cut_percent;
    translate([0, 0, depth]) union() {
        rotate([0, 90, 0]) translate([0, 0, -br]) cylinder(r=cut_width, h=ball_diameter);
        translate([-br, -cut_width/2, 0]) cube([ball_diameter, cut_width, ball_diameter]);
    }
}

module socket(
    ball_diameter = 16,
    wall_thickness = 1.8,
    opening_angle = 120,
    stem_length = 0,
    tunnel_diameter = 5,
    flex_depth_percent = 0.7,
    flex_cut_percent = 0.12
) {
    translate([0, 0, ball_diameter/2+stem_length]) difference() {
        rotate_extrude() {
            difference() {
                union() {
                    socket_wall(ball_diameter, wall_thickness, opening_angle);
                    socket_connector_wall(ball_diameter, tunnel_diameter, wall_thickness, stem_length);
                }
                translate([-ball_diameter+tunnel_diameter/2, -(ball_diameter*0.5+stem_length)]) square([ball_diameter, ball_diameter+stem_length]);
            }
        }
        flex_cut(ball_diameter, flex_depth_percent, flex_cut_percent);
        rotate([0, 0, 90]) flex_cut(ball_diameter, flex_depth_percent, flex_cut_percent);
    }
}

module ball(
    ball_diameter = 16,
    wall_thickness = 1.8,
    base_cutoff_percent = 0.2,
    stem_length = 0,
    tunnel_diameter = 5,
    small_ball_multiplier = 1.02
) {
    small_ball_diameter = (ball_diameter-wall_thickness*2)*small_ball_multiplier;
    translate([0, 0, small_ball_diameter/2+stem_length]) rotate_extrude() {
        difference() {
            union() {
                mirror([0, 1]) ball_wall(small_ball_diameter, wall_thickness, base_cutoff_percent);
                ball_connector_wall(small_ball_diameter, tunnel_diameter, wall_thickness, stem_length);
            }
            translate([-small_ball_diameter+tunnel_diameter/2, -(small_ball_diameter*0.5+stem_length)]) square([small_ball_diameter, small_ball_diameter+stem_length]);
        }
    }
}

module ball_joint(
    ball_diameter = 16,
    wall_thickness = 1.8,
    opening_angle = 120,
    base_cutoff_percent = 0.2,
    separation = 2,
    tunnel_diameter = 5,
    flex_depth_percent = 0.7,
    flex_cut_percent = 0.12,
    small_ball_multiplier = 1.02
) {
    union() {
        socket(ball_diameter, wall_thickness, opening_angle, separation/2, tunnel_diameter, flex_depth_percent, flex_cut_percent);
        mirror([0, 0, 1]) ball(ball_diameter, wall_thickness, base_cutoff_percent, separation/2, tunnel_diameter, small_ball_multiplier);
    }
}

ball_joint();