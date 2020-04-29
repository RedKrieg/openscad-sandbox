wire_size = 0.7; //smallest parts are 0.5 but we need to subtract this from the shell
wire_spacing = 2.5;
short_length = 14.5;
long_length = 15.5;
base_brim_height = 1.0;
led_body_diameter_low = 5.0;
led_body_diameter_high = 4.5;
led_body_precurve = 7.5;

$fn=100;

module led() {
    difference() {
        union() {
            cylinder(r1=led_body_diameter_low/2, r2=led_body_diameter_high/2, h=led_body_precurve);
            translate([0, 0, led_body_precurve]) sphere(r=led_body_diameter_high/2);
            translate([0, 0, base_brim_height/2]) rotate_extrude() translate([led_body_diameter_low/2, 0, 0]) circle(r=base_brim_height/2);
            translate([wire_spacing/2-wire_size/2, -wire_size/2, -short_length]) cube([wire_size, wire_size, short_length]);
            translate([-wire_spacing/2-wire_size/2, -wire_size/2, -long_length]) cube([wire_size, wire_size, long_length]);
        }
        translate([led_body_diameter_low/2,-led_body_diameter_low/2,0]) cube([led_body_diameter_low, led_body_diameter_low, base_brim_height]);
    }
}

led();