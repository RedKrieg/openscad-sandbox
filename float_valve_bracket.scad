tank_wall_thickness = 6;
valve_outer_diameter = 30;
throughole_diameter = 12;
wall_thickness = 2.5;
leg_length = 30;

$fn=101;

difference() {
    union() {
        cube([valve_outer_diameter, wall_thickness, valve_outer_diameter]);
        translate([-wall_thickness, -tank_wall_thickness/2-wall_thickness/2, 0]) cube([wall_thickness, tank_wall_thickness+2*wall_thickness, valve_outer_diameter]);
        translate([-valve_outer_diameter-wall_thickness, tank_wall_thickness/2+wall_thickness/2, 0]) cube([valve_outer_diameter, wall_thickness, valve_outer_diameter]);
        translate([-valve_outer_diameter-wall_thickness, -tank_wall_thickness/2-wall_thickness/2, 0]) cube([valve_outer_diameter, wall_thickness, valve_outer_diameter]);
    }
    translate([valve_outer_diameter/2, 5, valve_outer_diameter/2]) rotate([90, 0, 0]) cylinder(r=throughole_diameter/2, h=10);
}