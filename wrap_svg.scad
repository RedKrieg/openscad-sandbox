

// these next two functions are from https://openhome.cc/eGossip/OpenSCAD/2DtoCylinder.html
// https://www.thingiverse.com/thing:1589493
module one_over_fn_for_circle(radius, fn) {
    a = 360 / fn;
    x = radius * cos(a / 2);
    y = radius * sin(a / 2);
    polygon(points=[[0, 0], [x, y],[x, -y]]);
}

module square_to_cylinder(length, width, square_thickness, fn) {
    r = length / 6.28318;
    a = 360 / fn;
    y = r * sin(a / 2);
    for(i = [0 : fn - 1]) {
        // line up the triangle
        rotate(a * i) translate([0, -(2 * y * i + y), 0])
        // added this render because previews with high fn values break very quickly
        render() intersection() {
            // line up the triangle
            translate([0, 2 * y * i + y, 0]) 
                linear_extrude(width) 
                    one_over_fn_for_circle(r, fn);
            // make the character stand up
            translate([r - square_thickness, 0, width]) 
                rotate([0, 90, 0]) 
                    children(0);
        }
    }
}

/*
wrap_svg wraps an svg around a cylinder
- r is the outer radius of the cylinder
- thickness is the depth from r to extrude
- width and height are the dimensions of the svg file in pixels (you must provide these)
- scaler can grow or shrink the svg
- dpi is the resolution at which the svg should be imported in dots per inch (96 is the default for svg imports)
- center centers the svg toward the negative x axis instead of starting the svg at 0 degrees
- fn is the number of faces in which to divide the cylinder
*/
module wrap_svg(r, thickness, filename, width, height, scaler=1, dpi=96, center=false, fn=$fn) {
    svg_resolution = dpi / 25.4; // dpi -> pixels per mm
    circumference = 2*PI*r;
    centering_factor = center ? (circumference/scaler - width/svg_resolution)/2 : 0;
    square_to_cylinder(circumference, height*scaler/svg_resolution, thickness, fn)
        linear_extrude(thickness) scale(scaler)
            translate([height/svg_resolution, centering_factor, 0]) // move to positive quadrant and add centering factor
                rotate(90) import(filename, dpi=dpi);
}