wing_thickness = 3;
wing_width = 22;
wing_length = 40;
wing_angle = 22;
wing_count = 10;

rim_thickness = 2;
rim_height = wing_width * sin(wing_angle);

inner_radius = 25;
outer_radius = inner_radius + wing_length;

use <levitation_puck.scad>;

$fn=100;

module wing() {
    w = wing_width / 2;
    t = wing_thickness / 2;
    //quadratic equation solved for c where a=w and b=r-t
    radius = (t*t+w*w)/(2*t);
    rotate([wing_angle, 0, 0]) rotate([0, 90, 0]) intersection() {
        translate([-(radius-t), 0, 0])
            cylinder(h=wing_length+inner_radius, r=radius);
        translate([radius-t, 0, 0])
            cylinder(h=wing_length+inner_radius, r=radius);
    }
}

module fan() {
    union() {
        step=360/wing_count;
        for(i=[0:step:359]) {
            rotate([0, 0, i]) wing();
        }
        difference() {
            cylinder(r=outer_radius+rim_thickness, h=rim_height, center=true);
            cylinder(r=outer_radius, h=rim_height, center=true);
        }
        cylinder(r=inner_radius+rim_thickness, h=rim_height, center=true);
    }
}

difference() {
    fan();
    translate([0, 0, -10.4+rim_height/2-rim_thickness]) puck();
}