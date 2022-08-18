// https://github.com/openscad/scad-utils
use <scad-utils/morphology.scad>
// https://github.com/openscad/list-comprehension-demos
use <list-comprehension-demos/sweep.scad>
use <wrap.scad>

// standard 12 oz beer can
//inner_diameter = 66.8;
//inner_wall_height = 105;

// slim "white claw" can
inner_diameter = 58.2;
inner_wall_height = 140;

wall_thickness = 8;
logo_thickness = 0.5;

handle_opening_max_width = 45;
handle_opening_max_height = 120;

svg_filename = "whoopsie.svg";
svg_scale = 0.5;

$fn = $preview ? 25 : 255;

function ellipse(rx, ry) = [for (i=[0:$fn-1]) let (a=i*360/$fn) [rx * cos(a), ry * sin(a)]];

module coozy_shell() {
    rotate_extrude() {
        rounding(r=wall_thickness/2) {
            square([inner_diameter/2 + wall_thickness, wall_thickness]);
            translate([inner_diameter/2, 0]) square([wall_thickness, inner_wall_height + wall_thickness]);
        }
        // need this to prevent a "pucker" at the bottom center of the shell after rounding.
        square(wall_thickness);
    }
}

module handle(xscaler, yscaler) {
    //x values here are based on a butterworth function shown here: https://www.quora.com/What-is-a-good-square-wave-approximation-without-using-Fourier
    function f(t) = [
        xscaler/(1+pow(2.6*t-1.3, 8)), //function approximates the desired shape between -1.3 and 1.3, but the 8 here should be slightly higher.  For some reason higher values break something in sweep() and there will be "pinches" where the ellipse does not render correctly along the path.  I have yet to determine the reason for this.  The cos() on the z/y-axis below helps make up for the low power here.
        0,
        yscaler*cos(180*t) //smooths out the flares at the end of the butterworth
    ];
    function contour() = ellipse(8, 12);
    step = 1/$fn;
    path = [for (t=[0:step:1]) f(t)];
    path_transforms = construct_transform_path(path);
    sweep(contour(), path_transforms);
}

module mug() {
    union() {
        rotate([0, 0, 90]) translate([inner_diameter/2, 0, inner_wall_height/2+wall_thickness/2]) handle(handle_opening_max_width, handle_opening_max_height/2);
        coozy_shell();
    }
}

difference() {
    //mug();
    coozy_shell();
    wrap(
        r=inner_diameter/2+wall_thickness,
        h=inner_wall_height+wall_thickness,
        depth=logo_thickness,
        fn=$fn
    ) scale(svg_scale) import(svg_filename, center=true);
}
