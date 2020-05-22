$fn = 101;
large_radius = 8;
dimple_radius = 1;
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

difference() {
    sphere(large_radius);
    dimple(large_radius, dimple_radius, dimple_depth);
}