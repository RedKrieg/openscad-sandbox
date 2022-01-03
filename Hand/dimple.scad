$fa = $preview ? 12 : 4;
$fs = $preview ? 1 : 0.25;

large_radius = 6.2;
dimple_radius = 1; // [0:0.1:10]
dimple_depth = 0.25;
dimple_border = dimple_radius * 0.1;

// distance from center to plane intersecting edge of dimple
//   args: large sphere radius, dimple radius
function dimple_distance(lr, dr) = sqrt(lr * lr - dr * dr);
// radius of the small sphere to cut a dimple
//   args: dimple_radius, dimple_depth
function small_radius(dr, dd) = (dr * dr + dd * dd) / (2 * dd);
// distance from center to center of small sphere
//   args: large radius, dimple radius, dimple depth
function small_distance(lr, dr, dd) = dimple_distance(lr, dr) - dd + small_radius(dr, dd);

// places a sphere such that it intersects a centered sphere of r=large_radius to create a dimple of radius dimple_radius and depth of dimple_depth from the rim of the dimple
module dimple(large_radius, dimple_radius, dimple_depth) {
    sr = small_radius(dimple_radius, dimple_depth);
    sd = small_distance(large_radius, dimple_radius, dimple_depth);
    translate([sd, 0, 0]) sphere(r=sr);
}

function dimple_count(outer_radius, dimple_radius) = floor(360 / (2 * asin(dimple_radius/outer_radius)));

module ringed_ball(large_radius, dimple_radius, dimple_depth) {
    dimple_spacing = 360 / dimple_count(large_radius, dimple_radius);
    difference() {
        sphere(large_radius);
        for (i=[0:dimple_spacing:360]) {
            rotate([0, 0, i]) dimple(large_radius, dimple_radius, dimple_depth);
        }
    }
}

module recursive_dimples(large_radius, dimple_radius, dimple_depth, theta=0, phi=0, phi_min=-90, phi_max=90) {
    dc = dimple_count(large_radius * cos(phi), dimple_radius);
    if (dc > 0 && phi < phi_max && phi > phi_min) {
        dimple_spacing = 360 / dc;
        for (i=[0:dimple_spacing:360]) {
            rotate([0, phi, i + theta]) dimple(large_radius, dimple_radius, dimple_depth);
        }
        if (phi > 0) {
            recursive_dimples(large_radius, dimple_radius, dimple_depth, theta + dimple_spacing / 2, phi + dimple_spacing, phi_min, phi_max);
        } else if (phi < 0) {
            recursive_dimples(large_radius, dimple_radius, dimple_depth, theta - dimple_spacing / 2, phi - dimple_spacing, phi_min, phi_max);
        } else {
            recursive_dimples(large_radius, dimple_radius, dimple_depth, theta + dimple_spacing / 2, phi + dimple_spacing, phi_min, phi_max);
            recursive_dimples(large_radius, dimple_radius, dimple_depth, theta - dimple_spacing / 2, phi - dimple_spacing, phi_min, phi_max);
        }
    }
}

module spiral_dimples(large_radius, dimple_radius, dimple_depth, theta=0, phi=-90, phi_min=-90, phi_max=90) {
    // do not look at this, you will cry
    test_dc = dimple_count(large_radius * cos(phi), dimple_radius);
    if (test_dc > 0 && phi + 360 / test_dc <= phi_max && phi >= phi_min) {
        test_dimple_spacing = 360 / test_dc;
        dc = phi > 0 ? test_dc - 3 : dimple_count(large_radius * cos(phi + test_dimple_spacing), dimple_radius) - 3;
        dimple_spacing = 360 / dc;
        for (i=[0:dc]) {
            rotate([0, phi + i * dimple_spacing / dc, theta + i * dimple_spacing]) dimple(large_radius, dimple_radius, dimple_depth);
        }
        spiral_dimples(large_radius, dimple_radius, dimple_depth, theta=theta, phi=phi + dimple_spacing, phi_min=phi_min, phi_max=phi_max);
    }
}

module imported_ball(large_radius, dimple_radius, dimple_depth) {
    include <dimple_vectors.scad>
    difference() {
        sphere(large_radius);
        for (i=rotation_vectors) rotate(i) rotate([0, 90, 0]) dimple(large_radius, dimple_radius, dimple_depth);
    }
}

module fibonacci_ball(large_radius, dimple_radius, dimple_depth, dimple_count) {
    function phi(i) = acos(1 - 2 * i / dimple_count);
    function theta(i) = 180 * i * (1 + sqrt(5));
    difference() {
        sphere(large_radius);
        for (i=[0.5:1:dimple_count-0.5])
            rotate([0, phi(i), theta(i)]) rotate([0, 90, 0]) dimple(large_radius, dimple_radius, dimple_depth);
    }
}

module offset_fibonacci_ball(large_radius, dimple_radius, dimple_depth, dimple_count) {
    // http://extremelearning.com.au/how-to-evenly-distribute-points-on-a-sphere-more-effectively-than-the-canonical-fibonacci-lattice/
    epsilon = 1.33;
    function phi(i) = acos(1 - 2 * (i + epsilon) / (dimple_count - 1 + 2 * epsilon));
    function theta(i) = 180 * i / (1 + sqrt(5));
    difference() {
        sphere(large_radius);
        for (i=[0.5:1:dimple_count])
            rotate([0, phi(i), theta(i)]) rotate([0, 90, 0]) dimple(large_radius, dimple_radius, dimple_depth);
    }
}

module dimple_sphere(large_radius, dimple_radius, dimple_depth) {
    difference() {
        sphere(large_radius);
        spiral_dimples(large_radius, dimple_radius, dimple_depth, phi=-30, phi_min=-45, phi_max=45);
    }
}

//dimple_sphere(large_radius, dimple_radius, dimple_depth);
//imported_ball(large_radius, dimple_radius, dimple_depth);
fibonacci_ball(large_radius, dimple_radius, dimple_depth, 88);
