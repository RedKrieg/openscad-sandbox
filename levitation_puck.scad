puck_upper_radius = 25.1;
puck_upper_height = 7.2;
puck_lower_radius = 15.1;
puck_lower_height = 10.4-puck_upper_height;

$fn=100;

module puck() {
    union() {
        cylinder(r=puck_lower_radius, h=puck_lower_height);
        translate([0, 0, puck_lower_height]) cylinder(r=puck_upper_radius, h=puck_upper_height);
    }
}

module slot() {
    union() {
        puck();
        translate([-puck_lower_radius, 0, 0]) cube([puck_lower_radius*2, puck_upper_radius*2, puck_lower_height]);
        translate([-puck_upper_radius, 0, puck_lower_height]) cube([puck_upper_radius*2, puck_upper_radius*2, puck_upper_height]);
    }
}

difference() {
    translate([5.5, 5.5, 910]) import("apollo_command_module.stl");
    slot();
}