hole_diameter = 7.8;
hole_separation_x = 250;
hole_separation_y = 71;
strut_depth = 4;
strut_width = hole_diameter+strut_depth;
post_depth = 2.4;
panel_dimensions = [270, 175];
post_offsets = [10.5, 52];
label_depth = 0.4;

//this is a dumb offset used when planes intersect and the solver fails
delta = 0.0001;

//how far we go from the holes to clear the electronics box
electronic_box_clearance_y = post_offsets.y/2;

$fs = $preview ? 0.6 : 0.1;
$fa = $preview ? 20 : 2;

total_depth = strut_depth+post_depth;

m3_clearance_diameter = 3.2;
m3_short_blind_height = 4.0;
m3_short_blind_diameter = 4.0;
m3_long_blind_height = 3.0;
m3_long_blind_diameter = m3_clearance_diameter;
m3_short_offset = total_depth - m3_short_blind_height;
m3_brace_depth = 2;
m3_washer_diameter = 7.2;
m3_washer_height = strut_depth - m3_brace_depth;

tilt_angle = 36.8;

radio_hole_separation = 28;
radio_x_offset = 18;

module holes() {
    circle(d=hole_diameter);
    translate([0, hole_separation_y]) circle(d=hole_diameter);
}

module blind_hole_m3_short() {
    cylinder(h=m3_short_blind_height, d=m3_short_blind_diameter);
    translate([0, 0, -m3_long_blind_height]) cylinder(h=m3_long_blind_height, d=m3_long_blind_diameter);
}

module washer_disk_m3() {
    cylinder(h=m3_washer_height, d=m3_washer_diameter);
    translate([0, 0, -strut_depth]) cylinder(h=strut_depth, d=m3_clearance_diameter);
}

module rounded_strut(p1, p2, rotation=[0,0,0]) {
    hull()
    for(p=[p1, p2])
        translate(p) rotate(rotation)
        cylinder(h=strut_depth, d=strut_width);
}

module perpendicular_insert_pocket() {
    pocket_depth = m3_short_blind_height+m3_long_blind_height;
    rotate([0, 90, 0]) hull() {
        translate([0, 0, pocket_depth]) sphere(r=strut_width/2);
        translate([0, 0, 0]) cylinder(h=strut_width/2, r=strut_width/2);
    }
}

module face_bracket() {
    total_depth = strut_depth+post_depth;
    m3_short_offset = total_depth - m3_short_blind_height;
    difference() {
        union() {
            for(y=[0, hole_separation_y])
                translate([0, y, strut_depth])
                cylinder(h=post_depth, d=hole_diameter);
            rounded_strut([0, 0], [0, hole_separation_y]);
        }
        for(y=[0, hole_separation_y])
            translate([0, y, m3_short_offset])
            blind_hole_m3_short();
    }
}

module side_bracket() {
    x = hole_separation_x / 3;
    points = [
        [0, 0],
        [0, hole_separation_y],
        [x, -electronic_box_clearance_y],
        [x, hole_separation_y+electronic_box_clearance_y]
    ];
    pocket_translations = [
        [points[3].x-strut_width/2, points[3].y+electronic_box_clearance_y, strut_width/2],
        [points[2].x-strut_width/2, points[2].y-electronic_box_clearance_y, strut_width/2]
    ];
    thick_strut_translations = [
        [points[3].x, points[3].y+electronic_box_clearance_y-strut_width/2, 0],
        [points[2].x, points[2].y-electronic_box_clearance_y+strut_width/2, 0]
    ];
    difference() {
        union() {
            //cross struts
            for(p1=points, p2=points)
                if(p1!=p2) rounded_strut(p1, p2);
            //thicker struts
            hull() for(p=thick_strut_translations)
                translate(p) cylinder(h=m3_brace_depth+strut_depth, d=strut_width);
            // brackets
            for(i=[0:1])
                hull() {
                    translate(pocket_translations[i]) perpendicular_insert_pocket();
                    translate(thick_strut_translations[i]) cylinder(h=m3_brace_depth+strut_depth, d=strut_width);
                }
        }
        //holes for inserts
        for(p=[points[2], points[3]])
            translate([p.x, p.y, m3_brace_depth]) blind_hole_m3_short();
        for(p=[points[0], points[1]]) {
            //washer sinks
            translate([p.x, p.y, m3_brace_depth]) washer_disk_m3();
        }
        for(p=pocket_translations)
            translate(p+[m3_short_blind_height-delta, 0, 0]) rotate([0, -90, 0]) blind_hole_m3_short();
    }
}

module bolt_slot(length) {
    union() {
        hull() {
            cylinder(h=m3_washer_height, d=m3_washer_diameter);
            translate([length, 0, 0]) cylinder(h=m3_washer_height, d=m3_washer_diameter);
        }
        hull() {
            translate([0, 0, -strut_depth]) cylinder(h=strut_depth, d=m3_clearance_diameter);
            translate([length, 0, -strut_depth]) cylinder(h=strut_depth, d=m3_clearance_diameter);
        }
    }
}

module mounting_bracket() {
    x = hole_separation_x / 3;
    z_offset = strut_width/2+post_depth+strut_depth;
    points = [
        [x-strut_width/2, -post_offsets.y, z_offset],
        [x-strut_width/2, hole_separation_y+post_offsets.y, z_offset],
        [2*x+strut_width/2, hole_separation_y+post_offsets.y, z_offset],
        [2*x+strut_width/2, -post_offsets.y, z_offset]
    ];
    function calc_2d(points) = [ for (p=points) if (p.y < 0) [p.x, p.y+strut_width/2] else [p.x, p.y-strut_width/2] ];
    2d_points = calc_2d(points);
    slot_length = (2d_points[1].y-2d_points[0].y)/5;
    translate(points[1]) rotate([tilt_angle-90, 0, 0]) translate(-points[1]) difference() {
        union() {
            rounded_strut(points[0]+[0, 3*strut_width/2, 0], points[1], rotation=[0, -90, 0]);
            rounded_strut(points[2], points[3]+[0, 3*strut_width/2, 0], rotation=[0, 90, 0]);
            translate(points[0]) hull() {
                perpendicular_insert_pocket();
                translate([0, 3*strut_width/2, 0]) rotate([0, 90, 0]) cylinder(h=strut_depth/2, d=strut_width);
            }
            translate(points[3]) rotate([0, 180, 0]) hull() {
                perpendicular_insert_pocket();
                translate([0, 3*strut_width/2, 0]) rotate([0, 90, 0]) cylinder(h=strut_depth/2, d=strut_width);
            }
            translate([0, 0, z_offset+strut_width/2-strut_depth]) linear_extrude(strut_depth) difference() {
                polygon(2d_points);
                offset(delta=-strut_width) polygon(2d_points);
            }
        }
        //brace holes
        translate(points[0]+[m3_short_blind_height-delta, 0, 0]) rotate([0, -90, 0]) blind_hole_m3_short();
        translate(points[3]-[m3_short_blind_height-delta, 0, 0]) rotate([0, 90, 0]) blind_hole_m3_short();
        translate(points[2]+[strut_depth-m3_washer_height+delta, 0, 0]) rotate([0, 90, 0]) washer_disk_m3();
        translate(points[1]-[strut_depth-m3_washer_height+delta, 0, 0]) rotate([0, -90, 0]) washer_disk_m3();
        //bolt slots
        for(p=[
            points[0]+[strut_width/2, strut_width*2, strut_width/2-m3_washer_height-delta],
            points[0]+[strut_width/2, strut_width*2+slot_length*3, strut_width/2-m3_washer_height-delta],
            points[3]+[-strut_width/2, strut_width*2, strut_width/2-m3_washer_height-delta],
            points[3]+[-strut_width/2, strut_width*2+slot_length*3, strut_width/2-m3_washer_height-delta]
        ]) {
            translate(p) rotate([0, 0, 90]) mirror([0, 0, 1]) bolt_slot(slot_length);
        }
    }
}

module center_bracket() {
    x = hole_separation_x / 3;
    points = [
        [x, -electronic_box_clearance_y],
        [x, hole_separation_y+electronic_box_clearance_y],
        [2*x, hole_separation_y+electronic_box_clearance_y],
        [2*x, -electronic_box_clearance_y]
    ];
    bracket_offset_upper = strut_width/2 + strut_depth;
    bracket_offset_lower = strut_width/2 + strut_depth*2;
    difference() {
        union() {
            linear_extrude(strut_depth) difference() {
                offset(r=strut_width/2) polygon(points);
                offset(r=-strut_width/2) polygon(points);
            }
        }
        for(p=points)
            translate([p.x, p.y, m3_brace_depth]) washer_disk_m3();
        for(p=[points[3]-[radio_x_offset, 0], points[3]-[radio_x_offset+radio_hole_separation, 0]])
            translate([p.x, p.y, m3_brace_depth]) mirror([0, 0, 1]) washer_disk_m3();
    }
}

module angle_brace() {
    hypotenuse = panel_dimensions.y;
    theta = (90 - tilt_angle)/2;
    opposite = hypotenuse * sin(theta);
    length = opposite*2;
    points = [
        [0, 0, 0],
        [length, 0, 0]
    ];
    difference() {
        rounded_strut(
            points[0],
            points[1]
        );
        for(p=points) translate(p+[0, 0, strut_depth-m3_brace_depth]) washer_disk_m3();
        translate((points[1]-points[0])/2) mirror([1, 0, 0]) linear_extrude(label_depth) text(str(tilt_angle), size=3*strut_width/4, halign="center", valign="center");
    }
}

if($preview) {
    #color("red") for(x=[0, hole_separation_x], y=[0, hole_separation_y]) translate([x, y, strut_depth]) cylinder(h=post_depth, d=hole_diameter+0.2);
    color("#D0D0FF") for(x=[0, hole_separation_x])
        translate([x, 0, 0]) face_bracket();
    color("#40D040") translate([0, 0, total_depth]) side_bracket();
    color("#40D040") translate([hole_separation_x, hole_separation_y, total_depth]) rotate([0, 0, 180]) side_bracket();
    color("#D0D0FF") translate([0, 0, total_depth+strut_depth+m3_brace_depth]) center_bracket();
    #color("#C0C0C0") translate([strut_width/2-post_offsets.x, strut_width/2-post_offsets.y, strut_depth]) linear_extrude(post_depth) offset(r=strut_width/2) square(panel_dimensions-[strut_width, strut_width]);
    color("#D0D0FF") mounting_bracket();
    color("#D0D020") translate([hole_separation_x/3-strut_width/2, -post_offsets.y, total_depth+strut_depth+m3_brace_depth]) rotate([-90, -(90+tilt_angle)/2, 90]) angle_brace();
} else {
    //side_bracket();
    //face_bracket();
    center_bracket();
    //mounting_bracket();
    //angle_brace();
}