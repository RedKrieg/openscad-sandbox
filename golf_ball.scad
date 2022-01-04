$fa = $preview ? 8 : 4;
$fs = $preview ? 1.5 : 1;

large_radius = 21.35;
dimple_radius = 1.75; // [0:0.1:10]
dimple_depth = 0.18;
dimple_count = 360;

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
    translate([0, 0, sd]) sphere(r=sr);
}

module golf_ball(large_radius, dimple_radius, dimple_depth, dimple_count) {
    function phi(i) = acos(1 - 2 * i / dimple_count);
    function theta(i) = 180 * i * (1 + sqrt(5));
    difference() {
        sphere(large_radius);
        for (i=[0.5:1:dimple_count])
            rotate([0, phi(i), theta(i)]) dimple(large_radius, dimple_radius, dimple_depth);
    }
}

golf_ball(large_radius, dimple_radius, dimple_depth, dimple_count);
