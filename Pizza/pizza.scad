pizza_diameter = 35; // pizza diameter
crust_diameter = 2.6; // diameter of crust
layer_height = 0.2; // layer height for printing
base_height = 1.2; // height of the topping area of the pizza

$fs = layer_height;
$fa = 1;

pepperoni_diameter = 2.6;
pepperoni_count = 33;

green_pepper_diameter = 5;
green_pepper_width = 0.8;
green_pepper_extra_angle = 30;
green_pepper_count = 13;

slice_count = 8;
slice_angle = 360/slice_count;
slice_width = layer_height;

module base() {
    color("yellow") cylinder(h=base_height, d=pizza_diameter);
}

module crust() {
    color("yellow") difference() {
        translate([0, 0, base_height]) // move so center is at base_height
        rotate_extrude() // form toroid from
        translate([pizza_diameter/2-crust_diameter/2, 0]) //move circle to edge of crust
        circle(d=crust_diameter); // circle sized for crust
        mirror([0, 0, 1]) base(); // crop crust under base using mirrored base
    }
}

module pepperoni() {
    color("red")
    cylinder(h=base_height+layer_height, d=pepperoni_diameter); //single layer above base
}

module green_pepper() {
    color("green") rotate(rands(0, 360, 1)[0]) // randomize orientation
    translate([0, 0, base_height/2+layer_height])
    scale([1, 0.5, 1]) // squish in y direction
    rotate(-green_pepper_extra_angle/2) // even out the halves
    rotate_extrude(180+green_pepper_extra_angle) // only render a bit over half the pepper
    translate([green_pepper_diameter/2-green_pepper_width, -green_pepper_width, 0]) // move square to edge of pepper length
    square([green_pepper_width, base_height+layer_height*2]);
}

module distribute_toppings(topping_diameter, count=25) {
    // we square the max rand distance then take the sqrt of the result, this provides a distribution weighted more heavily toward the outside of the pizza to create a more uniform topping distribution while remaining inside the circle
    topping_angle = 360/count; // step angle for distributing toppings
    for (theta=[topping_angle:topping_angle:360])
        rotate(theta) // rotate to the desired angle for this topping
        translate([ // move to random distance
            sqrt( // square root of the square of the random result for uniformity
                rands(
                    topping_diameter/2, // don't put toppings in the very center
                    (pizza_diameter/2-crust_diameter/2-topping_diameter)^2, // and keep them away from the edge of the crust
                    1 // only return one random distance
                )[0] // choose the single distance (instead of passing a vector here)
            ),
            0, // don't move in y
            0 // don't move in z
        ]) children(); // any modules included after this one.
}

module slicer() {
    for (theta=[slice_angle:slice_angle:180])
        rotate(theta) // step angle for slicing pizza
        translate([
            -pizza_diameter/2+crust_diameter/2, // move slicer back half slicer length
            -slice_width/2, // and down half slicer width
            base_height-layer_height // sink layer_height of the way in to base_height
        ])
        cube([
            pizza_diameter-crust_diameter, // long enough to cut cheese without cutting crust (just like Cogan's, hahaha)
            slice_width, // how wide to make the slice gap
            base_height // make it tall enough to go through more than just cheese (in case we want bigger cuts later)
        ]);
}

module pizza(toppings=true) {
    union() { // combine 
        difference() { // this cuts slices in the base/toppings
            union() { // this is the base plus toppings
                base();
                if(toppings) {
                    distribute_toppings(pepperoni_diameter, pepperoni_count) pepperoni();
                    distribute_toppings(green_pepper_diameter, green_pepper_count) green_pepper();
                }
            }
            slicer(); // use boolean difference to slice
        }
        crust(); // add the crust after slicing
    }
}

module pizza_array() {
    for (x=[0:5], y=[0:1]) translate([(pizza_diameter+5)*x, (pizza_diameter+5)*y, 0]) rotate(20) pizza(true);
    for (x=[0:5], y=[2:3]) translate([(pizza_diameter+5)*x, (pizza_diameter+5)*y, 0]) rotate(20) pizza(false);
}

pizza_array();
