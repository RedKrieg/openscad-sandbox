//Vertical mount for "Google Pixel Stand (2nd gen)" found here https://store.google.com/product/pixel_stand_2nd_gen

// https://www.thingiverse.com/thing:1484333
use <geodesic_sphere.scad>

base_width_max = 72;
base_back_radius = 28;
base_depth = 76;
base_flat_depth = 25;
chin_rise = 6.5;
base_corner_radius = 13;
base_under_radius = 8;

bracket_width = 40;
bracket_height = 50;
bracket_wall_thickness = 6;

base_sf = 1.05;

round_by = 1.25;

$fn=16;

//module taken from the openscad wiki https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Tips_and_Tricks#Filleting_objects
module offset_3d(r=1, size=1000) {
    n = $fn==undef ? 12: $fn;
    if(r==0) children();
    else 
        if( r>0 )
            minkowski(convexity=5){
                children();
                geodesic_sphere(r, $fn=n);
            }
        else {
            size2 = size*[1,1,1];// this will form the positv
            size1 = size2*2;    // this will hold a negative inside
            difference(){
                cube(size2, center=true);// forms the positiv by substracting the negative        
                minkowski(convexity=5){
                    difference(){
                        cube(size1, center=true);
                        children();
                    }
                    geodesic_sphere(-r, $fn=n);
                }
            }
        }
}

module hull_base() {
    translate([0, 0, base_under_radius]) hull() {
        //rear_radius
        rotate_extrude(angle=180, $fn=48) {
            translate([base_back_radius, 0]) circle(base_under_radius, $fn=32);
        }
        //flat area
        translate([-base_width_max/2+base_under_radius, -base_flat_depth, 0]) geodesic_sphere(base_under_radius);
        translate([base_width_max/2-base_under_radius, -base_flat_depth, 0]) geodesic_sphere(base_under_radius);
        //chin
        chin_y = -base_depth+base_back_radius+base_corner_radius;
        translate([-base_width_max/2+base_corner_radius, chin_y, chin_rise]) scale([1, 1, base_under_radius/base_corner_radius]) geodesic_sphere(base_corner_radius);
        translate([base_width_max/2-base_corner_radius, chin_y, chin_rise]) scale([1, 1, base_under_radius/base_corner_radius]) geodesic_sphere(base_corner_radius);
    }
}

module screw_hole(thickness, screw_head_height=3.8, screw_shaft_radius=2.25, screw_head_radius=4.2) {
    translate([0, 0, thickness]) mirror([0, 0, 1]) {
        cylinder(h=screw_head_height, r1=screw_head_radius, r2=screw_shaft_radius);
        cylinder(h=thickness+0.001, r=screw_shaft_radius);
    }
}

module bracket() {
    rotate([0, 0, 135]) translate([-bracket_width/2, -bracket_height, 0]) difference() {
        union() {
            //horizontal
            cube([bracket_width, bracket_height, bracket_wall_thickness]);
            //vertical
            translate([0, 0, -bracket_height+bracket_wall_thickness]) cube([bracket_width, bracket_wall_thickness, bracket_height]);
            //bracer
            translate([bracket_width/2-bracket_wall_thickness/2, bracket_wall_thickness, 0]) rotate([0, 90, 0]) linear_extrude(bracket_wall_thickness) polygon([[0, 0], [bracket_height-bracket_wall_thickness, 0], [0, bracket_height-bracket_wall_thickness]]);
        }
        //screw holes
        translate([bracket_width/4, 0, -bracket_height/3]) rotate([-90, 0, 0]) screw_hole(bracket_wall_thickness);
        translate([3*bracket_width/4, 0, -2*bracket_height/3]) rotate([-90, 0, 0]) screw_hole(bracket_wall_thickness);
    }
}

module stand() {
    difference() {
        union() {
            scale([base_sf, base_sf, base_sf]) hull_base();
            bracket();
        }
        translate([0, 0, bracket_wall_thickness/2]) hull_base();
        translate([-base_depth, -base_depth, bracket_wall_thickness+2]) cube([base_depth*2, base_depth*2, base_depth*2]);
    }
}

module stand_rounded() {
    offset_3d(round_by) offset_3d(-round_by) stand();
}

if($preview) {
    stand();
} else {
    stand_rounded();
}
