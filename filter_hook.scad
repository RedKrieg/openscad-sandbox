use <list-comprehension-demos/sweep.scad>
use <scad-utils/shapes.scad>

bed_width = 100;
bed_height = 160;
bed_depth = 3;
hook_spacing = 70;
hook_radius = 3;
sweep_radius = 12;
sweep_degrees = 70;

$fn = 26;

module hook(hook_radius, sweep_radius, sweep_degrees) {
    function f(t) = [0, sweep_radius * cos(t*sweep_degrees), sweep_radius * sin(t*sweep_degrees)];
    step = 1 / $fn;
    path = [for (t=[0:step:1-step]) f(t)];
    translate([0, sweep_radius, 0]) rotate([0, 0, 180]) sweep(circle(hook_radius), construct_transform_path(path));
}

union() {
    translate([-bed_width/2, sweep_radius - bed_height, 0]) cube([bed_width, bed_height, bed_depth]);
    translate([-hook_spacing/2, 0, bed_depth]) hook(hook_radius, sweep_radius, sweep_degrees);
    translate([hook_spacing/2, 0, bed_depth]) hook(hook_radius, sweep_radius, sweep_degrees);
}