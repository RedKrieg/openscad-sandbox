$fn = $preview ? 16:64;
drive_side_length = 5.6;
inner_diameter_low = drive_side_length*sqrt(2);
inner_diameter_high = inner_diameter_low;
drive_height = 8;
cone_height = 2.4;
wall_thickness = 1.0;
prop_diameter = 90;
prop_thickness = 0.42;
prop_angle = 45;
prop_twist = 20;
prop_count = 5;
prop_scaler = 3;

module core(dsl, wt, dh, ch) {
    r = dsl*sqrt(2)/2+wt;
    difference() {
        union() { //shaft and nose cone
            cylinder(h=dh, r=r);
            translate([0, 0, dh]) rotate_extrude() intersection() {
                square(ch+r); //guaranteed to be large enough, just cutting the first quadrant
                scale([r, ch]) circle(1);
            }
        }
        
    }
}

module prop_profile_squished(ir, pr, ph) {
    rotate_extrude() difference() {
        scale([pr, ph/2]) circle(1);
        translate([-pr*2+ir, -ph/2]) square([pr*2, ph]);
    }
}

module prop_profile_torus(ir, pr, ph) {
    difference() {
        hull() rotate_extrude() translate([pr-ph/2, 0]) circle(ph/2);
        cylinder(h=ph, r=ir);
    }
}

module prop_profile(ir, pr, ph) {
    prop_profile_squished(ir, pr, ph);
}

module blade_flat(ir, pr, ph, pt, pc, pa, scaler, twist) {
    translate([0, -pt/2, -ph*sin(pa)]) union() {
        //cube([pr, pt, ph*2*sin(pa)]);
        rotate([0, -90, 0]) translate([ph*sin(pa), pt/2, 0]) mirror([0, 0, 1]) linear_extrude(pr, twist=twist*scaler, slices=$fn, scale=[scaler, 1]) translate([-ph*sin(pa), -pt/2]) let(r=pt/2) hull() {
            translate([r, r]) circle(r);
            translate([ph*2*sin(pa)-r, r]) circle(r);
        }
        translate([0, 0, ph*sin(pa)]) rotate([-90, 0, 0]) scale([ir-0.1,ph,pt]) cylinder(r=sin(pa), h=1);
    }
}

module blade(ir, pr, ph, pt, pc, pa, scaler, twist) {
    blade_flat(ir, pr, ph, pt, pc, pa, scaler, twist);
}

module prop(ir, pr, ph, pt, pc, pa, scaler, twist) {
    translate([0, 0, ph/2]) intersection() {
        prop_profile(ir, pr, ph);
        union(){
            for(theta=[0:360/pc:360-0.01]) {
                rotate([pa, 0, theta]) blade(ir, pr, ph, pt, pc, pa, scaler, twist);
            }
        }
    }
}

mirror([1, 0, 0]) difference() {
    union() {
        prop(ir=inner_diameter_low/2, pr=prop_diameter/2, ph=drive_height, pt=prop_thickness, pc=prop_count, pa=prop_angle, scaler=prop_scaler, twist=prop_twist);
        core(drive_side_length, wall_thickness, drive_height, cone_height);
    }
    linear_extrude(drive_height, scale=0.93) square(drive_side_length, center=true); //drive shaft socket
}