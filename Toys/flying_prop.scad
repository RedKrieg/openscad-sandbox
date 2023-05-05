$fn = $preview ? 16:64;
drive_side_length = 5.6;
inner_diameter_low = drive_side_length*sqrt(2);
inner_diameter_high = inner_diameter_low;
drive_height = 8;
cone_height = 1.6;
wall_thickness = 0.8;
prop_diameter = 75;
prop_thickness = 0.42;
prop_angle = 45;
prop_twist = 20;
prop_count = 3;
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
    //this is a sphere scaled to match the prop radius in X/Y and the prop height in Z
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
        rotate([0, -90, 0]) //orient horizontally
        translate([ph*sin(pa), pt/2, 0]) //uncenter
        mirror([0, 0, 1]) //rotate in the opposite direction
        linear_extrude(pr, twist=twist*scaler, slices=$fn, scale=[scaler, 1]) //twist here should not need the scaler multiplier, but there's something going on that makes this the only way I can compensate for the scale.  I need to implement my own extrude function later to fix this as it breaks down when scale is above 3 or with large twist values.
        translate([-ph*sin(pa), -pt/2]) //center for scaling during extrude
        let(r=pt/2) hull() { //just a simple rounded rectangle between two points
            translate([r, r]) circle(r);
            translate([ph*2*sin(pa)-r, r]) circle(r);
        }
        translate([0, 0, ph*sin(pa)]) rotate([-90, 0, 0]) scale([ir-0.1,ph,pt]) cylinder(r=sin(pa), h=1); //this is just a little extra material in case the prop is wider than the core
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