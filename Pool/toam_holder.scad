$fs = 0.2;
$fa = 0.2;

magnet_height = 2;
magnet_radius = 7.5;

chalk_radius = 12.75;
chalk_lip_height = 15;
chalk_top_height = 16.5;

layer_height = 0.2;
layer_count = 2;

wall_thickness = 1.6;

clearance = 0.05;

module base() {
    difference() {
        cylinder(
            h=chalk_lip_height+magnet_height+layer_height*layer_count*2,
            r=chalk_radius+wall_thickness
        );
        translate([0, 0, layer_height*layer_count]) cylinder(
            h=magnet_height,
            r=magnet_radius
        );
        translate([0, 0, layer_height*layer_count*4+magnet_height]) cylinder(
            h=chalk_top_height,
            r=chalk_radius
        );
    }
}

module lid() {
    difference() {
        cylinder(
            h=chalk_top_height,
            r=chalk_radius+wall_thickness*2+clearance
        );
        translate([0, 0, wall_thickness]) cylinder(
            h=chalk_top_height,
            r=chalk_radius+wall_thickness+clearance
        );
    }
}

module strap() {
    translate([magnet_radius+wall_thickness, -chalk_radius/2, 0]) cube([
        (chalk_lip_height+chalk_top_height)*2-magnet_radius,
        chalk_radius,
        layer_height*layer_count*2
    ]);
}

union() {
    base();
    translate([(chalk_lip_height+chalk_top_height)*2, 0, 0]) lid();
    strap();
}