use <wrap.scad>

band_thickness = 2.3; // [0.1:0.1:4]
band_width = 8.1; // [2:0.1:15]
ring_size = 9; // [0:0.5:20]

font = "Nautilus Pompilius:style=Regular";
text_depth = band_thickness/4;
text_string = "Hail Satan";

$fn=64;

/* [Hidden] */
size_zero = 11.53;
size_scaler = 0.824;

function inner_diameter_mm(x) = size_zero + size_scaler * x;
id = inner_diameter_mm(ring_size);

module size_deboss() {
    wrap(r=id/2+text_depth, h=band_width, depth=text_depth*2, fn=$fn) mirror([1, 0, 0]) text(str(ring_size), band_width/3, font, halign="center", valign="center");
}

module outer_text(text_string) {
    wrap(r=id/2+band_thickness+text_depth, h=band_width, depth=text_depth*2, fn=$fn) text(text_string, band_width/2, font, halign="center", valign="center");
}

difference() {
    rotate_extrude() translate([id/2+band_thickness/2, 0]) scale([band_thickness/2, band_width/2]) circle(1);
    //translate([0, id/2-band_thickness/8, 0]) rotate([90, 0, 0]) mirror([0, 0, 1]) linear_extrude(band_thickness/4) text(str(ring_size), band_width/3, font, halign="center", valign="center");
    translate([0, 0, -band_width/2]) rotate([0, 0, -90]) size_deboss();
    //my wrap function isn't perfect, so I rotate a tiny amount to eliminate thin walls
    translate([0, 0, -band_width/2]) rotate([0, 0, -90.001]) size_deboss();
    translate([0, 0, -band_width/2]) rotate([0, 0, 90]) outer_text(text_string);
}