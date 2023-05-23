line_width = 2;
figure_width = 100;
figure_thickness = 1;
logo_layout = [
    [true, false, false],
    [true, false, true],
    [true, true, false]
];
logo_height = 1.6;

segment_width = figure_width / 3;

$fn=64;

module line(w, h, a, b) {
    linear_extrude(h) hull() {
        translate(a) square(w, center=true);
        translate(b) square(w, center=true);
    }
}

function translate_circle(x, y) = [segment_width*x+segment_width/2, segment_width*y+segment_width/2];

union() {
    translate([-line_width/2, -line_width/2, -figure_thickness]) cube([figure_width+line_width, figure_width+line_width, figure_thickness]);
    for(x=[0:2], y=[0:2]) {
        if(logo_layout[x][y]) {
            translate(translate_circle(x, y)) cylinder(h=logo_height, r=segment_width/3);
        }
    }
    //vertical lines
    for (x=[0:3]) {
        line(line_width, logo_height, [segment_width*x, 0], [segment_width*x, figure_width]);
    }
    //horizontal lines
    for (y=[0:3]) {
        line(line_width, logo_height, [0, segment_width*y], [figure_width, segment_width*y]);
    }
}