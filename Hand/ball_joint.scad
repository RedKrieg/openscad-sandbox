//design is a clone of https://www.thingiverse.com/thing:889439
//I did not want the extra thin areas in the socket and wanted more of a rounded socket edge, hence this project.

//morphology library (for rounding) from https://github.com/openscad/scad-utils
use <scad-utils/morphology.scad>

$fn=101;

module socket_wall(diameter, wall_thickness, opening_angle) {
    r = diameter / 2;
    //radius for rounding is just under half of wall thickness because the rounding module can over-optimize when walls are less than 2*r
    rounding(r=wall_thickness * 0.499) difference() {
        circle(r=r);
        circle(r=r - wall_thickness);
        //this only works for opening_angle < 180, but if your socket is only half a socket, you're not going to be holding the ball for very long.
        rotate(90 - opening_angle / 2) square(r);
    }
}

module ball_wall(diameter, wall_thickness, base_cutoff_percent) {
    r = diameter / 2;
    cutoff_movement = r - diameter * base_cutoff_percent;
    difference() {
        circle(r=r);
        circle(r=r - wall_thickness);
        translate([0, cutoff_movement]) square(r);
    }
}

module connector_wall(ball_diameter, tunnel_diameter, wall_thickness, stem_length) {
    br = ball_diameter / 2;
    tr = tunnel_diameter / 2;
    difference() {
        translate([tr, -br-stem_length]) square([wall_thickness, br + stem_length]);
        circle(r=br - wall_thickness * 0.5);
    }
}

module flex_cut(ball_diameter, flex_depth_percent, flex_cut_percent) {
    br = ball_diameter / 2;
    depth = br - ball_diameter * flex_depth_percent;
    cut_width = br * flex_cut_percent;
    translate([0, 0, depth]) union() {
        rotate([0, 90, 0]) translate([0, 0, -br]) cylinder(r=cut_width, h=ball_diameter);
        translate([-br, -cut_width / 2, 0]) cube([ball_diameter, cut_width, ball_diameter]);
    }
}

module socket(
    ball_diameter = 16,
    wall_thickness = 1.8,
    opening_angle = 120,  //socket opening total angle
    stem_length = 0,
    tunnel_diameter = 5,
    flex_depth_percent = 0.7,  //depth of flex cut as percentage of diameter
    flex_cut_percent = 0.12  //round cut radius, flat cut width as percentage of diameter
) {
    translate([0, 0, ball_diameter / 2 + stem_length]) difference() {
        rotate_extrude() {
            fillet(r=wall_thickness*0.499) difference() {
                union() {
                    socket_wall(ball_diameter, wall_thickness, opening_angle);
                    connector_wall(ball_diameter, tunnel_diameter, wall_thickness, stem_length);
                }
                translate([-ball_diameter + tunnel_diameter / 2, -(ball_diameter * 0.5 + stem_length)]) square([ball_diameter, ball_diameter + stem_length]);
            }
        }
        flex_cut(ball_diameter, flex_depth_percent, flex_cut_percent);
        rotate([0, 0, 90]) flex_cut(ball_diameter, flex_depth_percent, flex_cut_percent);
    }
}

module ball(
    ball_diameter = 16,
    wall_thickness = 1.8,
    base_cutoff_percent = 0.2,  //percentage of diameter to cut off the end of the ball, values >= 0.5 are invalid
    stem_length = 0,
    tunnel_diameter = 5,
    small_ball_multiplier = 1.02,  //increase or decrease ball to snug (greater than 1.0) or loosen (less than 1.0) fit
    rounded_opening = true  //round the edges of the opening in the ball, lowers surface area, but increases diameter of cables that can fit through a bent joint
) {
    small_ball_diameter = (ball_diameter - wall_thickness * 2) * small_ball_multiplier;
    translate([0, 0, small_ball_diameter / 2 + stem_length]) rotate_extrude() {
        fillet(r=wall_thickness*0.499) difference() {
            union() {
                if (rounded_opening) {
                    //lower resolution to 15%, save $fn for use in the wall
                    fn = $fn;
                    rounding(r=wall_thickness * 0.15, $fn=ceil(fn * 0.15)) ball_wall(small_ball_diameter, wall_thickness, base_cutoff_percent, $fn=fn);
                } else {
                    ball_wall(small_ball_diameter, wall_thickness, base_cutoff_percent);
                }
                connector_wall(small_ball_diameter, tunnel_diameter, wall_thickness, stem_length);
            }
            translate([-small_ball_diameter + tunnel_diameter / 2, -(small_ball_diameter * 0.5 + stem_length)]) square([small_ball_diameter, small_ball_diameter + stem_length]);
        }
    }
}

module ball_joint(
    ball_diameter = 16,
    wall_thickness = 1.8,
    opening_angle = 120,
    base_cutoff_percent = 0.2,
    separation = 0,
    tunnel_diameter = 5,
    flex_depth_percent = 0.7,
    flex_cut_percent = 0.12,
    small_ball_multiplier = 1.02,
    rounded_opening = true
) {
    union() {
        socket(ball_diameter, wall_thickness, opening_angle, separation / 2, tunnel_diameter, flex_depth_percent, flex_cut_percent);
        mirror([0, 0, 1]) ball(ball_diameter, wall_thickness, base_cutoff_percent, separation / 2, tunnel_diameter, small_ball_multiplier, rounded_opening);
    }
}

ball_joint();
