//threads library from https://dkprojects.net/openscad-threads/
use <threads.scad>;
use <scad-utils/morphology.scad>;

collar_max_depth = 10;
collar_min_radius = 20;
collar_max_radius = 28;
base_radius = 30;
base_height = 90;
lantern_height = 110;

leg_radius = 5;

base_thickness = 3;
lantern_base_thickness = 5;
lantern_wall_thickness = 0.4;

base_scale = 1.5;
lantern_scale = 1.25;
lantern_twist = 180;
lantern_extrude_res = 500;
lantern_drawing_res = 40;

//od is measured at 39.42mm but 39.5mm is too tight even at a 45 degree thread angle (totally guessing 45 based on visual observation).  40mm od fits exactly the same as the included collar with the lanterns I have.
//https://smile.amazon.com/gp/product/B07BQRFHNK/ref=ppx_yo_dt_b_asin_title_o01_s00?ie=UTF8&psc=1
thread_od = 40;
thread_id = 38;
thread_pitch = 2.5;
thread_angle = 45;

$fn = 100;

module rounded_square(size, radius, fn=20) {
    $fn = fn;
    rounding(r=radius) square(size, center=true);
}

module lantern_wall_drawing(outer_size, radius, thickness, fn=20) {
    $fn = fn;
    shell(d=-thickness) rounded_square(outer_size, radius, fn=fn);
}

module leg_cutout(height, width, thickness) {
    translate([0, height/2, height+thickness]) rotate([90, 0, 0]) resize([width*2, height*2, height]) cylinder(h=height, r=width);
}

module base() {
    difference() {
        linear_extrude(height=base_height, scale=base_scale) rounded_square(collar_max_radius*2, leg_radius);
        translate([0, 0, base_thickness]) linear_extrude(height=base_height, scale=base_scale) rounded_square(collar_max_radius*2-base_thickness/2, leg_radius);
        cylinder(r=collar_min_radius, h=base_height);
        leg_cutout(base_height, collar_max_radius, base_thickness);
        rotate([0, 0, 90]) leg_cutout(base_height, collar_max_radius, base_thickness);
    }
}

module lantern() {
    difference() {
        union() {
            linear_extrude(height=lantern_height, scale=lantern_scale, twist=lantern_twist, $fn=lantern_extrude_res) lantern_wall_drawing(collar_max_radius*2, leg_radius, lantern_wall_thickness, fn=lantern_drawing_res);
            //linear_extrude(height=lantern_height, scale=lantern_scale, twist=-lantern_twist, $fn=lantern_extrude_res) lantern_wall_drawing(collar_max_radius*2, leg_radius, lantern_wall_thickness, fn=lantern_drawing_res);
            translate([0, 0, -lantern_base_thickness]) linear_extrude(height=lantern_base_thickness, $fn=lantern_extrude_res) rounded_square(collar_max_radius*2, leg_radius, fn=lantern_drawing_res);
        }
        translate([0, 0, -lantern_base_thickness]) metric_thread(thread_od, thread_pitch, lantern_base_thickness, internal=true, angle=thread_angle);
    }
}

//base();
lantern();