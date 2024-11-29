module star(r, points=5) {
    // half the angle between each point
    angle = 180.0/points;
    // every other radius is computed to imply connection to the neighbor after next
    // this breaks for points < 5
    function get_r(r, i) = r * (i % 2 == 0 ? 1.0 : cos(angle*2)/cos(angle));
    polygon([
        // use twice the number of points requested, every other one is half the radius
        for (i=[1:points*2]) [
            get_r(r, i) * cos(i*angle),
            get_r(r, i) * sin(i*angle)
        ]
    ]);
}

min_points=5;
max_points=15;
radius=10;
spacer=radius*2.5;
// full stars, vornoi roof
for (i=[min_points:max_points]) {
    translate([(i-min_points)*spacer, 0, 0]) roof() star(radius, points=i);
}

// full stars, straight roof
for (i=[min_points:max_points]) {
    translate([(i-min_points)*spacer, -spacer, 0]) roof(method = "straight") star(radius, points=i);
}

// hollow stars
for (i=[min_points:max_points]) {
    translate([(i-min_points)*spacer, spacer, 0]) roof(method = "straight") difference() {
        star(radius, points=i);
        star(radius/2, points=i);
    }
}
