use <ball_joint.scad>

knuckle_spacing = 25;
wrist_spacing = 35;
tunnel_diameter = 5;
wall_thickness = 1.8;
fingers = 4;

$fn = 101;

module knuckle_bar(fingers, knuckle_spacing, tunnel_diameter, wall_thickness) {
    linear_extrude(height=wall_thickness * 2) difference() {
        union() {
            translate([0, -tunnel_diameter / 2]) square([knuckle_spacing * (fingers - 1), tunnel_diameter]);
            for (i = [0:fingers - 1]) {
                translate([i * knuckle_spacing, 0]) circle(r=tunnel_diameter / 2 + wall_thickness);
            }
        }
        for (i = [0:fingers - 1]) {
            translate([i * knuckle_spacing, 0]) circle(r=tunnel_diameter / 2);
        }
    }
}

module knuckles(fingers, knuckle_spacing, tunnel_diameter, wall_thickness) {
    union() {
        translate([0, 0, -wall_thickness*2]) knuckle_bar(fingers, knuckle_spacing, tunnel_diameter, wall_thickness);
        for (i = [0:fingers - 1]) {
            translate([i * knuckle_spacing, 0, 0]) socket(tunnel_diameter = tunnel_diameter, wall_thickness = wall_thickness);
        }
        for (i = [0, fingers - 1]) {
            translate([i * knuckle_spacing, 0, -wall_thickness * 2]) mirror([0, 0, 1]) ball(tunnel_diameter = tunnel_diameter, wall_thickness = wall_thickness);
        }
    }
}

knuckles(fingers, knuckle_spacing, tunnel_diameter, wall_thickness);