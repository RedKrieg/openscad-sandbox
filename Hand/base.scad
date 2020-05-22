use <scad-utils/morphology.scad>
use <ball_joint.scad>

$fn = 101;
sides = 6;
lower_radius = 90;
upper_radius = 85;
ball_radius = 5.5;  //base of ball

module base(sides, lower_radius, upper_radius, ball_radius) {
    theta = 360/sides;
    fn = $fn;
    rise = lower_radius-upper_radius;
    rotate_extrude($fn=sides) {
        translate([upper_radius, 0], $fn=fn) difference() {
            circle(r=rise);
            translate([-rise, 0]) square(rise);
            translate([-rise, -rise*2]) square(rise*2);
        }
        square([upper_radius, rise]);
    }
    for (i=[0:theta:360-theta]) {
        rotate([0, 0, i]) translate([upper_radius - ball_radius, 0, rise]) socket();
    }
}

base(sides, lower_radius, upper_radius, ball_radius);