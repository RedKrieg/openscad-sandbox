text_size = 24;
text_voffset = text_size/4*3;
text_font = "Alex Brush:style=Regular";
text_depth = 1;
back_width = 200;
back_height = 100;
back_depth = 3;
border_width = 5;

module fucking_text() {
    linear_extrude(height=1) union() {
        translate([0, text_voffset, 0]) text("Rinse your", font=text_font, size=text_size, halign="center", valign="center");
        translate([0, -text_voffset, 0]) text("fucking dishes.", font=text_font, size=text_size, halign="center", valign="center");
    }
}

union() {
    difference() {
        translate([0, 0, back_depth/2]) cube([back_width, back_height, back_depth], center=true);
        translate([0, 0, back_depth]) cube([back_width-border_width*2, back_height-border_width*2, text_depth], center=true);
    }
    translate([0, 0, back_depth-text_depth]) fucking_text();
}