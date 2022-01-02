$fn = $preview ? 32 : 64;
sphere_radius = 30.25;
staff_radius = 27.2;
staff_socket_depth = 40;
wall_thickness = 3;

crystal_radius1 = 22;
crystal_radius2 = 16;
crystal_h1 = 20;
crystal_h2 = 60;
crystal_h3 = 14;
crystal_faces = 6;

led_radius = 6;
led_height = 37;
led_nub_radius = 3;
led_nub_height = 6;

tentacle_count = 8;
tentacle_segments = 11;
tentacle_shrink_factor = 0.87;
tentacle_bend_angle = [1, 9, -26];
tentacle_initial_angle = [3, 0, -58];
tentacle_radius_base = (staff_radius+wall_thickness) * 0.75 * PI / tentacle_count;
tentacle_length_base = tentacle_radius_base * 2;

module tentacle_segment(l, r) {
    sphere(r=r);
    cylinder(h=l, r1=r, r2=r*tentacle_shrink_factor);
}

module tentacle(segments, l, r) {
    if(segments>0) {
        tentacle_segment(l, r);
        translate([0, 0, l]) rotate(tentacle_bend_angle) tentacle(segments-1, l*tentacle_shrink_factor, r*tentacle_shrink_factor);
    } else {
        sphere(r=r);
    }
}

module tentacle_complete() {
    for(i=[0:360/tentacle_count:359]) {
         rotate([0,0,i]) translate([staff_radius+wall_thickness-tentacle_radius_base, 0, 0]) rotate(tentacle_initial_angle) tentacle(tentacle_segments, tentacle_length_base, tentacle_radius_base);
    }
}

module crystal(h1, h2, h3, r1, r2, faces) {
    translate([0, 0, h2+h3]) cylinder(h=h1, r1=r1, r2=0, $fn=faces);
    translate([0, 0, h3]) cylinder(h=h2, r1=r2, r2=r1, $fn=faces);
    cylinder(h=h3, r1=0, r2=r2, $fn=faces);
}

module led() {
    translate([0, 0, led_nub_height]) cylinder(h=led_height-led_radius-led_nub_height, r=led_radius);
    translate([0, 0, led_height-led_radius]) sphere(r=led_radius);
    cylinder(h=led_nub_height, r=led_nub_radius);
}

module staff_socket() {
    cylinder(h=staff_socket_depth, r=staff_radius);
}

module base_bulk() {
    cylinder(h=staff_socket_depth+wall_thickness, r=staff_radius+wall_thickness);
    translate([0, 0, staff_socket_depth+wall_thickness]) cylinder(h=led_height, r1=staff_radius+wall_thickness, r2=crystal_radius2-wall_thickness);
}

module base_complete() {
    difference() {
        union() {
            base_bulk();
            translate([0, 0, staff_socket_depth+wall_thickness]) tentacle_complete();
        }
        translate([0, 0, staff_socket_depth+wall_thickness+led_height/2])
                crystal(crystal_h1, crystal_h2, crystal_h3,
                    crystal_radius1, crystal_radius2, crystal_faces);
        staff_socket();
        translate([0, 0, staff_socket_depth+wall_thickness]) led();
    }
}

module crystal_complete() {
    translate([0, 0, staff_socket_depth+wall_thickness]) difference() {
        translate([0, 0, led_height/2]) crystal(crystal_h1, crystal_h2, crystal_h3,crystal_radius1, crystal_radius2, crystal_faces);
        led();
    }
}

crystal_complete();
base_complete();


/*
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
*/