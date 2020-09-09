// these next two functions are modified from https://openhome.cc/eGossip/OpenSCAD/2DtoCylinder.html
// https://www.thingiverse.com/thing:1589493
module one_over_fn_for_circle(radius, fn) {
    a = 360 / fn;
    x = radius * cos(a / 2);
    y = radius * sin(a / 2);
    polygon(points=[[0, 0], [x, y], [x, -y]]);
}

module square_to_cylinder(r, width, fn) {
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
            // make the object stand up
            translate([r, 0, width]) 
                rotate([0, 90, 0]) 
                    children(0);
        }
    }
}

/*
wraps any 2d drawing around a cylinder, centering the origin on the face near negative X (off by 180/fn to match openscad polygon faces)
- r is the outer radius of the cylinder
- h is the height of the cylinder
- depth is how far in from the surface the drawing should be extruded
- fn is the number of faces to divide in to (higher is slower)
*/
module wrap(r, h, depth, fn=$fn) {
    corner_radius = r / cos(180/fn);
    circumference = 2*PI*corner_radius;
    square_to_cylinder(corner_radius, h, fn)
        mirror([0, 0, 1]) linear_extrude(depth)
            translate([h/2, circumference/2])
                rotate(90)
                    children(0);
}

/*
wraps a 3d model around a cylinder, must be ENTIRELY IN NEGATIVE Z
*/
module wrap3d(r, h, fn=$fn) {
    corner_radius = r / cos(180/fn);
    circumference = 2*PI*corner_radius;
    square_to_cylinder(corner_radius, h, fn)
        translate([h/2, circumference/2])
            rotate(90)
                children(0);
}