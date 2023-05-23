use <wrap.scad>

ring_size = 12; // [0:0.5:20]
band_width = 8.1; // [2:0.1:15]
band_thickness = 2.3; // [0.1:0.1:4]
font = "Nautilus Pompilius:style=Regular";
text_depth = band_thickness/3;
$fn=64;
/* [Hidden] */
size_zero = 11.53;
size_scaler = 0.824;
function inner_diameter_mm(x) = size_zero + size_scaler * x;

module size_deboss(id, size) {
    wrap(r=id/2+text_depth, h=band_width, depth=text_depth*2, fn=$fn) text(str(size), band_width/1.5, font, halign="center", valign="center");
}

for(size=[4:0.5:14]) {
    translate([0, 0, -size*band_width*2]) difference() {
        cylinder(h=band_width, r2=inner_diameter_mm(size-0.25)/2, r1=inner_diameter_mm(size+0.25)/2);
        size_deboss(inner_diameter_mm(size), size);
    }
}