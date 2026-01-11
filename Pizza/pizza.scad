diameter = 25;
crust_diameter = 2;
layer_height = 0.2;
base_height = 0.8;

$fs = layer_height;
$fa = 1;

pepperoni_diameter = 1.6;
pepperoni_count = 33;
pepperoni_angle = 360/pepperoni_count;

slice_count = 8;
slice_angle = 360/slice_count;
slice_width = layer_height;

module base() {
    cylinder(h=base_height, d=diameter);
}

module crust() {
    difference() {
        translate([0, 0, base_height]) rotate_extrude() translate([diameter/2-crust_diameter/2, 0]) circle(d=crust_diameter);
        mirror([0, 0, 1]) base(); // crop crust under base
    }
}

module pepperoni() {
    cylinder(h=base_height+layer_height, d=pepperoni_diameter);
}

module pepperonis() {
    // we square the max rand distance then take the sqrt of the result, this provides a distribution weighted more heavily toward the outside of the pizza to create a more uniform pepperoni distribution
    for (theta=[pepperoni_angle:pepperoni_angle:360]) rotate(theta) translate([sqrt(rands(pepperoni_diameter/2, (diameter/2-crust_diameter/2-pepperoni_diameter/2)^2, 1)[0]), 0, 0]) pepperoni();
}

module slicer() {
    for (theta=[slice_angle:slice_angle:360]) rotate(theta) translate([-diameter/2+crust_diameter/2, -slice_width/2, base_height-layer_height]) cube([diameter-crust_diameter, slice_width, base_height]);
}

module pizza(pepperoni=true) {
    union() {
        difference() {
            union() {
                base();
                if(pepperoni)
                    pepperonis();
            }
            slicer();
        }
        crust();
    }
}

for (x=[0:5], y=[0:1]) translate([(diameter+5)*x, (diameter+5)*y, 0]) pizza(true);
for (x=[0:5], y=[2:3]) translate([(diameter+5)*x, (diameter+5)*y, 0]) pizza(false);