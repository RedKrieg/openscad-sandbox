//kryptonite u-lock to rear rack clip by Brandon Whaley <redkrieg@gmail.com>
//measure your rack and lock, insert the values of their respective radii below

// linear distance between center of bracket and center of lock rails
centerdiff = 11; // [10:16]
// increase for a wider clip
height = 10; // [2:25]
// measured radius of bike rack bracket
bracket_radius = 5.2; // [4:9.5]
// measured radius of lock
lock_radius = 8.0; // [4:9]
// increase to add material to the clip
clip_thickness = 4; // [2:5]
// size of clip opening in degrees
clip_opening_degrees = 45;
// distance between center of rack and center of rack rail
bracket_center_radius = 65; // [45:69.8]
// distance between center of lock and center of lock rail
lock_center_radius = 58.85; // [54:82]
center_radius = (bracket_center_radius + lock_center_radius) / 2;
clip_rotation = asin((bracket_center_radius - center_radius)/centerdiff);
$fn=100; //smoother circles

module rounded_ring(inner_r, thickness, degrees) {
    // gets the number of degrees for step `n` of the loop
    function get_degrees(n) = (360-degrees)*n/$fn;
    //turn half the gap so we're aligned along the x axis
    rotate([0, 0, degrees/2]) for(i=[0:$fn-1])
        //hull the current and next steps together
        hull() {
            rotate([0, 0, get_degrees(i)]) translate([inner_r+thickness/2, 0]) circle(thickness/2);
            rotate([0, 0, get_degrees(i+1)]) translate([inner_r+thickness/2, 0]) circle(thickness/2);
        }
}

module conjoined_rings() {
    // bracket clip
    translate([-centerdiff, 0, 0]) mirror([1, 0, 0]) rounded_ring(bracket_radius, clip_thickness, clip_opening_degrees);
    // lock clip
    translate([centerdiff, 0, 0]) rounded_ring(lock_radius, clip_thickness, clip_opening_degrees);
    // connecting material
    translate([(bracket_radius-lock_radius)/2, 0, 0]) square([centerdiff-lock_radius-bracket_radius+clip_thickness*2, bracket_radius*2], center=true);
}

module full_clip() {
    square([clip_thickness, center_radius*2], center=true);
    //these rotate the clips such that the distance from 0 to the center of the bracket clip is bracket_center_radius.  because of the center_radius translation, this results in the lock clip being correctly centered
    translate([0,-center_radius,0]) rotate([0, 0, clip_rotation]) conjoined_rings();
    translate([0,center_radius,0]) rotate([0, 0, -clip_rotation]) conjoined_rings();
    
}

linear_extrude(height) full_clip();