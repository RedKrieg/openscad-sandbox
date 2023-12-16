//kryptonite u-lock to rear rack clip by Brandon Whaley <redkrieg@gmail.com>
//measure your rack and lock, insert the values of their respective radii below

// linear distance between center of bracket and center of lock rails
centerdiff = 11; // [10:16]
// increase for a wider clip
height = 10; // [5:25]
// measured radius of bike rack bracket
bracket_radius = 5.3; // [4:9.5]
// measured radius of lock
lock_radius = 8.0; // [4:9]
// increase to add material to the clip
clip_thickness = 4; // [2:5]
// distance between center of rack and center of rack rail
bracket_center_radius = 65; // [45:69.8]
// distance between center of lock and center of lock rail
lock_center_radius = 58.85; // [54:82]
center_radius = (bracket_center_radius + lock_center_radius) / 2;
clip_rotation = asin((bracket_center_radius - center_radius)/centerdiff);
$fn=100; //smoother circles

module clip() //this is one side of the full clip
{
    difference()
    {
        union()
        {
            translate([-centerdiff, 0, 0]) //bracket side of clip
            {
                cylinder(height, r=bracket_radius + clip_thickness, center=true);
            }
            translate([centerdiff, 0, 0]) //lock side of clip
            {
                cylinder(height, r=lock_radius + clip_thickness, center=true);
            }
            cube([centerdiff + clip_thickness, bracket_radius*2, height], center=true); //connector between clips
        }
        union()
        {
            translate([-centerdiff, 0, 0]) //cutout for bracket rail
            {
                cylinder(height*2, r=bracket_radius, center=true);
            }
            translate([centerdiff, 0, 0]) //cutout for lock rail
            {
                cylinder(height*2, r=lock_radius, center=true);
            }
            translate([-(centerdiff+bracket_radius+clip_thickness/2), 0, 0]) //opening for bracket insertion
            {
                cylinder(height*2, r=bracket_radius, center=true);
            }
            translate([(centerdiff+lock_radius+clip_thickness/2), 0, 0]) //opening for lock insertion
            {
                cylinder(height*2, r=lock_radius*1.10, center=true); //change 1.10 here to increase/decrease opening for lock rail
            }
        }
    }
}
union() {
    cube([clip_thickness, center_radius*2, height], center=true); //connector between sides
    //these rotate the clips such that the distance from 0 to the center of the bracket clip is bracket_center_radius.  because of the center_radius translation, this results in the lock clip being correctly centered
    translate([0,-center_radius,0]) rotate([0, 0, clip_rotation]) clip();
    translate([0,center_radius,0]) rotate([0, 0, -clip_rotation]) clip();
}