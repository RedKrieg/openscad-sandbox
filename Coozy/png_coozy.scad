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

// outer shell wall thickness
wall_thickness = 8;

handle_opening_max_width = 45;
handle_opening_max_height = 120;
render_handle = false;

// I recommend max resolution of 200x200px for images
png_filename = "dick_butt.png";
// 1.0 scale is 1px/mm, shrink as needed based on your outer circumference
png_scale = 0.76;
// by default, white will be deeply embossed and black will be at the outer radius.  this will invert the depth map
png_invert = true;
// maximum cut depth in to surface
png_depth = 1;

// this is due to the way 0 width walls work in openscad, added to the radius of the image
nonzero_buffer = 0.05;

// this just needs to be massive enough to get 100% coverage of the entire surface of the coozy
cut_cube_size = (inner_diameter * 2 + inner_wall_height * 2) * PI;

// use a high resolution for renders.
$fn = $preview ? 25 : 255;

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

// generate an ellipse as a series of points, used for the handle
function ellipse(rx, ry) = [for (i=[0:$fn-1]) let (a=i*360/$fn) [rx * cos(a), ry * sin(a)]];

module handle(xscaler, yscaler) {
    // x values here are based on a butterworth function shown here: https://www.quora.com/What-is-a-good-square-wave-approximation-without-using-Fourier
    function f(t) = [
        xscaler/(1+pow(2.6*t-1.3, 8)), // function approximates the desired shape between -1.3 and 1.3, but the 8 here should be slightly higher.  For some reason higher values break something in sweep() and there will be "pinches" where the ellipse does not render correctly along the path.  I have yet to determine the reason for this.  The cos() on the z/y-axis below helps make up for the low power here.
        0,
        yscaler*cos(180*t) // smooths out the flares at the end of the butterworth
    ];
    function contour() = ellipse(8, 12);
    step = 1/$fn;
    path = [for (t=[0:step:1]) f(t)];
    path_transforms = construct_transform_path(path);
    sweep(contour(), path_transforms);
}

// coozy with handle
module mug() {
    union() {
        rotate([0, 0, 90]) translate([inner_diameter/2, 0, inner_wall_height/2+wall_thickness/2]) handle(handle_opening_max_width, handle_opening_max_height/2);
        coozy_shell();
    }
}

// convert a png image to a surface map
module mirror_image() {
    // we will be using the "inner" surface to do a boolean difference on the surface of our coozy, so it needs to be mirrored.  we also need it in the negative Z axis for wrap, so we kill two birds with one stone here
    mirror([0, 0, 1])
        // for some reason the surface function with inversion on renders in negative Z, so we have to move it to match the non-inverted surface.  center doesn't affect the Z axis for this function because...  reasons?
        translate([0, 0, png_invert ? png_depth : 0])
            // scale results in a height map ranging from 0->100 (black->white), so we first divide by 100 then multiply by the desired thickness
            scale([png_scale, png_scale, 1/100*png_depth])
                surface(png_filename, center=true, invert=png_invert);
}

difference() {
    if(render_handle) {
        mug();
    } else {
       coozy_shell();
    }
    wrap3d(
        r=inner_diameter/2+wall_thickness+nonzero_buffer,
        h=inner_wall_height+wall_thickness,
        fn=$fn
    ) mirror_image();
}