line_width = 2;
plaque_width = 100 - line_width;
plaque_height = 2*plaque_width;
text_data = "807";
characters = len(text_data);
figure_thickness = 2;
font_size = 50;
font_height = 1.6;
font_style = "Nautilus Pompilius:style=Regular";
font_horizontal_offset = 0;

$fn=64;

module line(w, h, a, b) {
    linear_extrude(h) hull() {
        translate(a) square(w, center=true);
        translate(b) square(w, center=true);
    }
}

color("#e0ffe0") translate([-line_width/2, -line_width/2, -figure_thickness]) cube([plaque_width+line_width, plaque_height+line_width, figure_thickness]);
color("black") for (i=[0, 1]) {
    line(line_width, font_height, [plaque_width*i, 0], [plaque_width*i, plaque_height]);
    line(line_width, font_height, [0, plaque_height*i], [plaque_width, plaque_height*i]);
}
color("black") for (i=[0:characters-1]) {
    linear_extrude(font_height) translate([plaque_width/2+font_horizontal_offset, plaque_height/characters*(characters-i-0.5)]) text(text_data[i], font_size, font_style, halign="center", valign="center");
}
