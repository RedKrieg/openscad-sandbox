$fn = $preview ? 16:64;
inner_diameter_low = 4;
inner_diameter_high = 3.6;
wall_thickness = 0.8;
height = 7;
prop_diameter = 42;
prop_thickness = 0.6;
prop_angle = 45;
prop_twist = 15;
prop_count = 5;

module core(irl, irh, wt, h) {
    difference() {
        cylinder(h=h, r1=irl+wt, r2=irh+wt);
        cylinder(h=h, r1=irl, r2=irh);
    }
}

module prop_profile(ir, pr, ph) {
    difference() {
        scale([pr, ph/2]) circle(1);
        translate([-pr*2+ir, -ph/2]) square([pr*2, ph]);
    }
}

module prop(ir, pr, ph, pt, pc, pa, twist) {
    translate([0, 0, ph/2]) intersection() {
        rotate_extrude() prop_profile(ir, pr, ph);
        union(){
            for(theta=[0:360/pc:360-0.01]) {
                rotate([pa, 0, theta]) translate([0, -pt/2, -ph*sin(pa)]) union() {
                    //cube([pr, pt, ph*2*sin(pa)]);
                    rotate([0, -90, 0]) translate([ph*sin(pa), pt/2, 0]) mirror([0, 0, 1]) linear_extrude(pr, twist=twist, slices=$fn) translate([-ph*sin(pa), -pt/2]) let(r=pt/2) hull() {
                        translate([r, r]) circle(r);
                        translate([ph*2*sin(pa)-r, r]) circle(r);
                    }
                    translate([0, 0, ph*sin(pa)]) rotate([-90, 0, 0]) scale([ir-0.1,ph,pt]) cylinder(r=sin(pa), h=1);
                }
            }
        }
    }
}

union() {
    prop(ir=inner_diameter_low/2, pr=prop_diameter/2, ph=height, pt=prop_thickness, pc=prop_count, pa=prop_angle, twist=prop_twist);
    core(inner_diameter_low/2, inner_diameter_high/2, wall_thickness, height);
}