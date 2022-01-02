$fn = 64;
sphere_radius = 30.25;
staff_radius = 27.2;
wall_thickness = 5;

module claw() {
    translate([0, 0, - sphere_radius / 2]) cube([(sphere_radius + wall_thickness) * 2, wall_thickness * 2, sphere_radius + 3 * wall_thickness / 2], center=true);
}

union() {
    translate([0, 0, sphere_radius + wall_thickness]) difference() {
        union() {
            intersection() {
                union() {
                    claw();
                    rotate([0, 0, 45]) claw();
                    rotate([0, 0, 90]) claw();
                    rotate([0, 0, 45+90]) claw();
                }
                sphere(r = sphere_radius + wall_thickness);
            }
            translate([0, 0, -(sphere_radius + wall_thickness)]) cylinder(h = wall_thickness + sphere_radius / 3, r1 = staff_radius + wall_thickness, r2 = sphere_radius - wall_thickness);
        }
        sphere(r = sphere_radius);
    }
    translate([0, 0, -sphere_radius / 3]) difference() {
        cylinder(h=sphere_radius / 3, r=staff_radius + wall_thickness);
        cylinder(h=sphere_radius / 3, r=staff_radius);
    }
}