use <geodesic_sphere.scad>

part = "assembly";  // [assembly, dial, spring, shaft, endcaps]

digits = 10;
dial_count = 3;
dial_thickness = 8;
dial_radius = 12.7;
dial_knob_radius = 1.2;
dial_chamfer = 0.6;
min_thickness = 1.6;
tooth_depth = 0.8;
shaft_radius = 3.5;
arm_arc = 360;
spring_pretension = 0.4;
clearance = 0.05;
text_height = 0.5;
invert_text = true;
font="Leto:Style=Black";
text_size = 2 * PI * dial_radius / digits - dial_knob_radius * 2;

$fs = 0.1;
$fa = 6;

spring_height = dial_thickness - min_thickness - clearance;
segment_angle = is_undef($fa) ? (is_undef($fn) ? 15 : $fn) : $fa;

module dial_shell() {
    difference() {
        union() {
            cylinder(h=dial_thickness, r=dial_radius, $fn=digits); //outer profile
            for (theta=[360/digits:360/digits:360])
                rotate([0, 0, theta]) dial_knob();
        }
        cylinder(h=dial_thickness, r=shaft_radius+clearance/2); //center hole
        translate([0, 0, min_thickness]) cylinder(h=dial_thickness-min_thickness, r=dial_radius-min_thickness);

    }
}

module dial_tooth() {
    //translate([shaft_radius, 0, 0]) rotate([0, 0, 0])
    tooth_point = dial_radius - tooth_depth - min_thickness;
    theta = 360/digits;
    inner_radius = dial_radius - min_thickness;
    linear_extrude(dial_thickness)
        polygon([
            [tooth_point*cos(theta/2), tooth_point*sin(theta/2)],
            [inner_radius, 0],
            [dial_radius, 0],
            [dial_radius*cos(theta), dial_radius*sin(theta)],
            [inner_radius*cos(theta), inner_radius*sin(theta)]
        ]);
}

module dial_teeth() {
    mirror([1, 0, 0]) intersection() {
        cylinder(h=dial_thickness, r=dial_radius, $fn=digits); //outer profile
        union() for(theta=[360/digits:360/digits:360])
            rotate([0, 0, theta]) dial_tooth();
    }
}

module dial_digits() {
    theta = 360/digits;
    short_radius = dial_radius * cos(theta/2) - (invert_text?text_height-0.001:0);
    for (i=[0:digits-1]) {
        rotate([0, 0, i*theta]) translate([short_radius*cos(theta/2), short_radius*sin(theta/2), dial_thickness/2]) rotate([0, 90, theta/2]) linear_extrude(text_height) text(text=str(i), size=text_size, halign="center", valign="center", font=font);
    }
}

module dial_knob() {
    translate([dial_radius-dial_knob_radius/2, 0, 0]) cylinder(h=dial_thickness, r=dial_knob_radius);
}

module dial_chamfer() {
    rotate_extrude($fn=digits) polygon([
        [dial_radius-dial_chamfer, dial_thickness],
        [dial_radius*2, dial_thickness],
        [dial_radius*2, 0],
        [dial_radius-dial_chamfer, 0],
        [dial_radius-dial_chamfer+dial_thickness/2, dial_thickness/2]
    ]);
}

module dial() {
    difference() {
        union() {
            dial_shell();
            dial_teeth();
            if (! invert_text) {
                dial_digits();
            }
        }
        dial_chamfer();
        if (invert_text) {
            dial_digits();
        }
    }
}

module spring_core() {
    difference() {
        cylinder(h=spring_height, r=shaft_radius+min_thickness);
        shaft(dial_thickness, negative=true); //hole
    }
}

module spring_arm_segment(theta) {
    total_distance = dial_radius - shaft_radius - min_thickness*2 - tooth_depth;
    step = total_distance/arm_arc;
    rotate([0, 0, theta]) translate([shaft_radius+clearance+theta*step, 0, 0]) cube([min_thickness-clearance, clearance, spring_height]);
}

module spring_tab() {
    outer_radius = dial_radius - min_thickness;
    hull() {
        rotate([0, 0, arm_arc]) translate([outer_radius-tooth_depth+spring_pretension, 0, 0])
            cylinder(h=spring_height, r=tooth_depth);
        spring_arm_segment(arm_arc-segment_angle);
        spring_arm_segment(arm_arc);
    }
}

module spring_arm() {
    for(theta=[segment_angle:segment_angle:arm_arc-segment_angle]) {
        hull() {
            spring_arm_segment(theta);
            spring_arm_segment(theta-segment_angle);
        }
    }
}

module spring() {
    spring_core();
    for(theta=[180:180:360]) rotate([0, 0, theta]) union() {
        spring_arm();
        spring_tab();
    }
}

module wiggle_spring_tab() {
    outer_radius = dial_radius - min_thickness;
    hull() {
        rotate([0, 0, arm_arc]) translate([outer_radius-tooth_depth+spring_pretension, 0, 0])
            cylinder(h=spring_height, r=tooth_depth);
        wiggle_spring_arm_segment(arm_arc-segment_angle);
        wiggle_spring_arm_segment(arm_arc);
    }
}
module wiggle_spring_arm_segment(theta) {
    total_distance = (dial_radius - shaft_radius - min_thickness*2 - tooth_depth);
    step = total_distance/arm_arc;
    translate([shaft_radius+min_thickness/2+clearance+theta*step, min_thickness*sin(theta), 0]) cylinder(r=min_thickness/3, h=spring_height);
}
module wiggle_spring_arm() {
    for(theta=[segment_angle:segment_angle:arm_arc-segment_angle]) {
        hull() {
            wiggle_spring_arm_segment(theta);
            wiggle_spring_arm_segment(theta-segment_angle);
        }
    }
}
module wiggle_spring() {
    spring_core();
    for(i=[0,1]) mirror([i, 0, 0]) union() {
        wiggle_spring_arm();
        wiggle_spring_tab();
    }
}

module shaft(h, negative=false) {
    difference() {
        cylinder(h=h, r=shaft_radius+(negative?clearance/2:0));
        translate([-shaft_radius+(negative?0:clearance/2), 0, 0]) cylinder(h=h, r=min_thickness*1.5, $fn=3);
    }
}

module endcap() {
    theta = 360/digits;
    difference() {
        hull() {
            difference() {
                union() {
                    cylinder(h=dial_thickness, r=dial_radius, $fn=digits);
                    for (i=[360/digits:360/digits:360])
                        rotate([0, 0, i]) dial_knob();
                    }
                dial_chamfer();
            }
            translate([0, 0, dial_thickness])
                cylinder(h=min_thickness, r=3*dial_radius/4);
        }
        shaft(dial_thickness, negative=false); //hole
        // indicator notch
        rotate([0, 0, theta/2]) translate([dial_radius*cos(theta/2), 0, 0])
            union() {
                cylinder(h=dial_thickness/2, r=min_thickness/2);
                translate([0, 0, dial_thickness/2]) sphere(min_thickness/2);
            }
    }
}

module assembly() {
    dial();
    mirror([0, 1, 0]) translate([0, 0, min_thickness]) spring();
    shaft(dial_thickness);
    translate([0, 0, -clearance]) mirror([0, 0, 1]) endcap();
}

if (part == "assembly") {
    assembly();
} else if (part == "dial") {
    dial();
} else if (part == "spring") {
    spring();
} else if (part == "shaft") {
    //dial_count+2 for endcaps
    shaft((dial_count+2)*dial_thickness);
} else if (part == "endcaps") {
    endcap();
    translate([dial_radius*3, 0, 0]) mirror([1, 0, 0]) endcap();
}
