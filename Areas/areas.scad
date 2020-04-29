inch=25.4;
stroke=1.2;
height=1.2;
font_size=inch/8;
$fn=40;

module tag(txt) {
    rotate([90, 0, 0]) difference(){
        cylinder(stroke, inch/4, inch/4);
        translate([0, 0, stroke/2]) linear_extrude(height=stroke/2) text(txt, size=font_size, font="FreeSerif", valign="bottom", halign="center");
        translate([-inch/4, -inch/2, 0]) cube([inch/2, inch/2, stroke]);
    }
}

module status_box(txt) {
    union(){
        difference(){
            translate([-inch/2-stroke, -inch/2-stroke, 0]) cube([inch+stroke*2, inch+stroke*2, height]);
            translate([-inch/2, -inch/2, 0]) cube([inch, inch, height]);
        }
        translate([0, -inch/2, height]) tag(txt);
        rotate([0, 0, 180]) translate([0, -inch/2, height]) tag(txt);
    }
}

function is_in_radius(r, x, y) = sqrt(x*x+y*y) < r;

module effect_radius_base(boxes, stroke) {
    union() {
        for(x = [-boxes : 1 : boxes-1], y = [-boxes : 1 : boxes-1]) {
            x_center = x*inch+inch/2;
            y_center = y*inch+inch/2;
            if (is_in_radius(boxes*inch, x_center, y_center)) {
                translate([x*inch-stroke, y*inch-stroke, 0]) cube([inch+stroke*2, inch+stroke*2, height]);
            }
        }
    }
}

module effect_radius(r) {
    boxes = r/5;
    union() {
        difference() {
            effect_radius_base(boxes, stroke);
            effect_radius_base(boxes, 0);
        }
        translate([0, -inch*boxes, height]) tag(str(r));
        rotate([0, 0, 180]) translate([0, -inch*boxes, height]) tag(str(r));
    }
}

module matrix_base(matrix, stroke) {
    union() {
        for (x = [0 : 1 : len(matrix)-1]) {
            for (y = [0 : 1 : len(matrix[x])-1]) {
                if (matrix[x][y] != 0) {
                    translate([x*inch-stroke, y*inch-stroke, 0]) cube([inch+stroke*2, inch+stroke*2, height]);
                }
            }
        }
    }
}

module diagonal_cone(r) {
    boxes = r/5;
    matrix = [for (x = [0 : 1 : boxes-1]) [for (y = [0 : 1 : boxes-1]) x >= y ? 1 : 0 ] ];
    union() {
        difference() {
            matrix_base(matrix, stroke);
            matrix_base(matrix, 0);
        }
        translate([boxes*inch/2, 0, height]) tag(str(r));
        translate([boxes*inch/2, ceil(boxes/2)*inch, height]) rotate([0, 0, 180]) tag(str(r));
    }
}

module straight_cone(r) {
    //TODO - actually use r...
    matrix = [[0,1,0],[1,1,1],[1,1,1]];
    boxes = r/5;
    union() {
        difference() {
            matrix_base(matrix, stroke);
            matrix_base(matrix, 0);
        }
        translate([boxes*inch/2, 0, height]) tag(str(r));
        translate([boxes*inch/2, boxes*inch, height]) rotate([0, 0, 180]) tag(str(r));
    }
}

module square_base(boxes, stroke) {
    union() {
        for(x = [0 : 1 : boxes-1], y = [0 : 1 : boxes-1]) {
            translate([x*inch-stroke, y*inch-stroke, 0]) cube([inch+stroke*2, inch+stroke*2, height]);
        }
    }
}

module square(l) {
    boxes = l/5;
    union() {
        difference() {
            square_base(boxes, stroke);
            square_base(boxes, 0);
        }
        translate([boxes/2*inch, 0, height]) tag(str(l));
        translate([boxes/2*inch, inch*boxes, height]) rotate([0, 0, 180]) tag(str(l));
    }
}
//effect_radius(10);
//status_box("CON");
//diagonal_cone(15);
//straight_cone(15);
square(60);