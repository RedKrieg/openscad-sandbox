width = 24;
thickness = 5.3;
headphone_width = 60;

screw_head_radius = 4.2;
screw_head_height = 3.8;
screw_shaft_radius = 4.42 / 2;

screw_edge_clearance = 0.8;

$fn=101;

module hook() {
    cube([width, width, thickness]);
    translate([0, thickness, 0]) rotate([90, 0, 0]) cube([width, width, thickness]);
    translate([width/2-thickness/2, thickness, thickness]) linear_extrude(height=width+headphone_width, scale=[1, 0.25]) {
        square([thickness, width-3*thickness/2]);
        translate([thickness/2, width-3*thickness/2]) circle(r=thickness/2);
        translate([thickness/2, 0]) circle(r=thickness/2);
    }
    translate([width/2, thickness, width+headphone_width+thickness]) sphere(r=thickness);
}

module screwhole() {
    translate([0, 0, thickness]) mirror([0, 0, 1]) {
        cylinder(h=screw_head_height, r1=screw_head_radius, r2=screw_shaft_radius);
        cylinder(h=thickness+0.001, r=screw_shaft_radius);
    }
}

difference() {
    hook();
    translate([screw_head_radius+screw_edge_clearance, thickness+screw_head_radius+screw_edge_clearance, 0]) screwhole();
    translate([width-(screw_head_radius+screw_edge_clearance), width-(screw_head_radius+screw_edge_clearance), 0]) screwhole();
    translate([screw_head_radius+screw_edge_clearance, 0, width-(screw_head_radius+screw_edge_clearance)]) rotate([-90, 0, 0]) screwhole();
    translate([width-(screw_head_radius+screw_edge_clearance), 0, thickness+screw_head_radius+screw_edge_clearance]) rotate([-90, 0, 0]) screwhole();
}