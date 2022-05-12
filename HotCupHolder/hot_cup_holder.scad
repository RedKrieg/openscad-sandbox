holder_radius_upper = 40.0;
holder_radius_lower = 34.0;
holder_height = 70.0;
holder_thickness = 1.6;

ridge_radius = holder_thickness/2;
ridge_circumference_upper = 2 * PI * (ridge_radius+holder_radius_upper);
ridge_count = floor(ridge_circumference_upper / ridge_radius / 2);
ridge_step = 360/ridge_count;

$fn=16;

module ridge_circles(inner_radius) {
    for (theta = [0:ridge_step:360]) {
        rotate([0, 0, theta]) translate([inner_radius+ridge_radius, 0]) circle(r=ridge_radius);
    }
}

module ridges_inner() {
    rotate([0, 0, ridge_step/2]) intersection() {
        circle(r=holder_radius_upper+ridge_radius, $fn=ridge_count*2);
        ridge_circles(holder_radius_upper);
    }
}

module ridges_outer() {
    difference() {
        ridge_circles(holder_radius_upper);
        circle(r=holder_radius_upper+ridge_radius, $fn=ridge_count*2);
    }
}

module ridges() {
    ridges_outer();
    ridges_inner();
}

module holder() {
    linear_extrude(holder_height, scale = (holder_radius_lower+ridge_radius)/(holder_radius_upper+ridge_radius)) ridges();
}

holder();