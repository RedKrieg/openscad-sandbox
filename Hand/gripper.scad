use <ball_joint.scad>
use <scad-utils/morphology.scad>

radius = 16;
grip_angle = 18;
teeth = 5;
tooth_height = 1.2;
tooth_spacing = 2;
width = 5;
thickness = 1.4;
ball_x_max = 11;  // lets us have flats on the ball for printing on side
$fn = 101;

module gripper_teeth(teeth, height, spacing) {
    for (i=[0:teeth - 1]) {
        translate([i*spacing, 0]) polygon([[0, 0], [spacing/2, height], [spacing, 0]]);
    }
}

module gripper_head_male(teeth, tooth_height, tooth_spacing, width) {
    linear_extrude(height=width) translate([tooth_height, 0]) union() {
        gripper_teeth(teeth, tooth_height, tooth_spacing);
        polygon([
            [-tooth_height, 0],
            [-tooth_height, -tooth_height * 2],
            [tooth_spacing*teeth, -tooth_height],
            [tooth_spacing*teeth, 0]
        ]);
    }
}

module gripper_head_female(teeth, tooth_height, tooth_spacing, width) {
    linear_extrude(height=width) translate([tooth_height, 0]) difference() {
        polygon([
            [0, -tooth_height],
            [-tooth_height, 0],
            [-tooth_height, tooth_height * 2],
            [tooth_spacing*teeth, tooth_height],
            [tooth_spacing*teeth, -tooth_height]
        ]);
        translate([0, -tooth_height]) gripper_teeth(teeth, tooth_height, tooth_spacing);
    }
}

module arm_cutaway(radius, grip_angle, width, thickness) {
    function near_stop_location(r) = [r * cos(grip_angle / 2), r * sin(grip_angle / 2)];
    function far_stop_location(r) = [r * cos(grip_angle * 2), r * sin(grip_angle * 2)];
    linear_extrude(height=width / 2) difference() {
        intersection() {
            difference() {
                circle(r=radius + thickness / 2);
                circle(r=radius - thickness / 2);
            }
            polygon([
                [0, 0],
                [2 * radius, 0],
                far_stop_location(2 * radius)
            ]);
        }
        translate(far_stop_location(radius)) circle(r=thickness / 2);
    }
}

module gripper_arms(radius, grip_angle, thickness, width) {
    difference() {
        linear_extrude(height=width) difference() {
            circle(r=radius + thickness / 2);
            circle(r=radius - thickness / 2);
        }
    }
}

module gripper(radius, grip_angle, teeth, tooth_height, tooth_spacing, thickness, width, ball_x_max) {
    function x(theta) = 2 * radius * cos(theta);
    function y(theta) = 2 * radius * sin(theta);
    theta = grip_angle / 4;
    translate([0, 0, radius + thickness / 2]) rotate([0, -90, 0]) translate([0, 0, -width / 2]) difference() {
        union() {
            gripper_arms(radius, grip_angle, thickness, width);
            rotate([0, 0, grip_angle / 2]) translate([radius, 0, 0]) gripper_head_male(teeth, tooth_height, tooth_spacing, width);
            rotate([0, 0, -grip_angle / 2]) translate([radius, 0, 0]) gripper_head_female(teeth, tooth_height, tooth_spacing, width);
        }
        linear_extrude(height=width) {
            polygon([
                [0, 0],
                [x(theta), y(theta)],
                [x(-theta), y(-theta)]
            ]);
        }
        arm_cutaway(radius, grip_angle, width, thickness+0.01);
        translate([0, 0, width]) rotate([180, 0, 0]) arm_cutaway(radius, grip_angle, width, thickness+0.01);
    }
    intersection() {
        translate([0, 0, thickness]) mirror([0, 0, 1]) ball(stem_length=thickness);
        translate([-ball_x_max/2, -radius*2, -radius*2]) cube([ball_x_max, radius*4, radius*4]);
    }
}

gripper(radius, grip_angle, teeth, tooth_height, tooth_spacing, thickness, width, ball_x_max);
