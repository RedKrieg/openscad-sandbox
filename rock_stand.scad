$fn = 101;

base_thickness = 2;
cup_radius = 15;
cup_depth = 1.5;
support_thickness = 2;

rock_points = [
    [0, 0, 5],
    [25, 25, 0],
    [-15, 30, 10]
];

// radius of the small sphere to cut a dimple
//   args: dimple_radius, dimple_depth
function small_radius(dr, dd) = (dr * dr + dd * dd) / (2 * dd);

// just a series of hexagons on a grid to be removed from the base
module pits(base_thickness, wall_thickness, radius) {
    y_spacing = 2 * radius * sin(60) + wall_thickness;
    x_spacing = y_spacing * cos(30);
    linear_extrude(height=base_thickness) {
        for (x=[-10:10], y=[-10:10]) {
            translate([x*x_spacing, y*y_spacing + abs(x%2)*y_spacing/2]) circle(r=radius, $fn=6);
        }
    }
}

// wall_thickness here is used to set the minimum thickness of the wall as measured inside the cylinder, not the maximum measured outside.  as such, the outer surface has hexagon walls thicker than wall_thickness
module hex_cylinder(h, r, wall_thickness) {
    internal_radius = r - wall_thickness;
    x_spacing = r * sin(60) / 2 + wall_thickness; // this is the ideal spacing for hexes of radius r/4;
    circumference = 2 * internal_radius * PI; // use internal radius here to ensure wall thickness is always > wall_thickness.  replace internal_radius with r if you'd rather have the external walls appear to be wall_thickness wide
    hex_count = floor(circumference / x_spacing); // calculate how many of the hexes of radius r/4 can fit around the cylinder
    theta = 360 / hex_count; // find the angle that each hex should sweep over
    y_spacing = circumference / hex_count * cos(30); // use the actual space taken up by each hex around the circumference to calculate the spacing between layers of the array of hexes
    hex_radius = (circumference / hex_count - wall_thickness) / 2 / sin(60); // find the actual radius for our hexagon to ensure wall_thickness is obeyed for the internal radius, this basically reverses the x_spacing calculation above
    difference() {
        cylinder(h=h, r=r); // outer surface
        cylinder(h=h, r=r - wall_thickness); // inner surface
        // t is angle for rotation, z is row number for translation upward
        for (t=[0:theta:360], z=[0:1:h / y_spacing + 1]) {
            translate([0, 0, z * y_spacing]) rotate([0, -90, t + theta * abs(z % 2) / 2]) cylinder(r=hex_radius, h=r + wall_thickness, $fn=6);
        }
    }
}

// TODO: modularize
union() {
    // base outer lip
    difference() {
        hull() for (point = rock_points) translate([point[0], point[1], 0]) cylinder(h=base_thickness, r1=cup_radius+support_thickness, r2=cup_radius);
        hull() for (point = rock_points) translate([point[0], point[1], 0]) cylinder(h=base_thickness, r1=cup_radius-support_thickness, r2=cup_radius-support_thickness);
    }
    // base hex mesh
    difference() {
        hull() for (point = rock_points) translate([point[0], point[1], 0]) cylinder(h=base_thickness, r=cup_radius-support_thickness);
        pits(base_thickness, support_thickness, cup_radius/4);
    }
    // construct towers
    for (point = rock_points) {
        difference() {
            translate([point[0], point[1], 0]) union() {
                // base
                cylinder(h=base_thickness, r=cup_radius);
                // hex shell
                translate([0, 0, base_thickness]) hex_cylinder(h=point[2], r=cup_radius, wall_thickness=support_thickness);
                // solid for cup cutout
                translate([0, 0, base_thickness + point[2] - support_thickness]) cylinder(h=cup_depth + support_thickness, r=cup_radius);
            }
            dx = point[2] + base_thickness;
            sr = small_radius(cup_radius - support_thickness, cup_depth);
            sd = dx + sr - point[2];
            // cup cutout
            translate(point + [0, 0, sd]) sphere(r=sr);
        }
    }
}