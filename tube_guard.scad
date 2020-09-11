use <scad-utils/morphology.scad>

tube_diameter = 41.9;
guard_radius_offset = 30.0;
tab_width = 1.0;
tab_depth = 0.4;
spiral_wavelength = 100.0; // length of tube over which a spiral completes one turn
ring_thickness = 1;
guard_thickness = 3;
grip_height = 10;


$fn=101;

module ring() {
    linear_extrude(height=grip_height, twist=-360*grip_height/spiral_wavelength) union() {
        difference() {
            circle(r=tube_diameter/2+ring_thickness);
            circle(r=tube_diameter/2);
        }
        translate([-tab_width/2, -tube_diameter/2]) square([tab_width, tab_depth]);
    }
}

module guard() {
    rotate_extrude() rounding(r=guard_thickness/4) translate([tube_diameter/2, 0]) polygon([
        [0, 0],
        [0, grip_height],
        [ring_thickness, grip_height],
        [guard_thickness, guard_thickness],
        [guard_radius_offset-guard_thickness, guard_thickness],
        [guard_radius_offset, grip_height],
        [guard_radius_offset+guard_thickness, grip_height],
        [guard_radius_offset, 0]
    ]);
}

union() {
    guard();
    ring();
}