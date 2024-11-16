module star(r, points=5) {
    // half the angle between each point
    angle = 180.0/points;
    polygon([
        // use twice the number of points requested, every other one is half the radius
        for (i=[1:points*2]) [
            r * (i % 2 == 0 ? 1.0 : 0.5) * cos(i*angle),
            r * (i % 2 == 0 ? 1.0 : 0.5) * sin(i*angle)
        ]
    ]);
}

// full stars
for (i=[2:10]) {
    translate([i*25-50, 0, 0]) roof(method = "straight") star(10, points=i);
}

// hollow stars
for (i=[2:10]) {
    translate([i*25-50, 25, 0]) roof(method = "straight") difference() {
        star(10, points=i);
        star(5, points=i);
    }
}