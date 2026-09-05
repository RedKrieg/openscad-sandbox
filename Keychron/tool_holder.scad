$fs=0.2;
$fa=0.5;

screw_hole_max_diameter=7.6;
screw_hole_min_diameter=7;
screw_hole_clearance=0.2;
screw_hole_gap=150;
screw_hole_nub_height=13;
keyboard_base_height_lifted=14;
keyboard_depth_flat=110;
tool_holder_height=45;
tool_holder_depth=75;
tool_holder_extra_width=45;
tool_holder_wall_spacings=[30, 60, 90];
tool_holder_corner_rounding=3;
wall_thickness=1.8;
screw_y_translation=screw_hole_max_diameter-screw_hole_clearance;

module nub() {
    cylinder(h=screw_hole_nub_height, d1=screw_hole_max_diameter-screw_hole_clearance, d2=screw_hole_min_diameter-screw_hole_clearance);
    sphere(d=screw_hole_max_diameter-screw_hole_clearance);
    translate([0, 0, screw_hole_nub_height]) sphere(d=screw_hole_min_diameter-screw_hole_clearance);
}

module nubs() {
    translate([(screw_hole_max_diameter)/2, screw_y_translation/2, keyboard_base_height_lifted]) rotate([2*asin(keyboard_base_height_lifted/keyboard_depth_flat), 0, 0]) nub();
    translate([(screw_hole_max_diameter)/2+screw_hole_gap, screw_y_translation/2, keyboard_base_height_lifted]) rotate([2*asin(keyboard_base_height_lifted/keyboard_depth_flat), 0, 0]) nub();
}

module base() {
    hull() {
        translate([(screw_hole_max_diameter)/2, screw_y_translation/2, 0]) cylinder(h=keyboard_base_height_lifted, d=screw_hole_max_diameter-screw_hole_clearance);
        translate([(screw_hole_max_diameter)/2+screw_hole_gap, screw_y_translation/2, 0]) cylinder(h=keyboard_base_height_lifted, d=screw_hole_max_diameter-screw_hole_clearance);
    }
}

module tall_nubs() {
    nubs();
    translate([(screw_hole_max_diameter)/2, screw_y_translation/2, 0]) cylinder(h=keyboard_base_height_lifted, d=screw_hole_max_diameter-screw_hole_clearance);
    translate([(screw_hole_max_diameter)/2+screw_hole_gap, screw_y_translation/2, 0]) cylinder(h=keyboard_base_height_lifted, d=screw_hole_max_diameter-screw_hole_clearance);
}

module cylindered_cube(total_x, total_y, total_z, rounding) {
    hull() {
        for(
            x=[
                rounding,
                total_x-rounding
            ],
            y=[
                rounding,
                total_y-rounding
            ]) {
                translate([x, y, 0]) cylinder(h=total_z, r=rounding);
        }    
    }
}

module rounded_cube(total_x, total_y, total_z, rounding) {
    hull() {
        for(
            x=[
                rounding,
                total_x-rounding
            ],
            y=[
                rounding,
                total_y-rounding
            ],
            z=[
                rounding,
                total_z-rounding
            ])
            {
                translate([x, y, z]) sphere(r=rounding);
        }
    }
}

module tool_holder_cutter(offset_x, offset_y) {
    difference() {
        translate([
            offset_x,
            offset_y,
            screw_hole_nub_height
        ]) cube([
            tool_holder_extra_width*2+screw_hole_gap,
            tool_holder_height-screw_hole_nub_height/2,
            tool_holder_height-screw_hole_nub_height
        ]);
        translate([
            offset_x,
            tool_holder_height-screw_hole_nub_height/2+offset_y,
            screw_hole_nub_height,
        ]) rotate([0, 90, 0]) cylinder(
            h=tool_holder_extra_width*2+screw_hole_gap,
            r=tool_holder_height-screw_hole_nub_height
        );
    }
}

module tool_holder_outer() {
    translate([
        (screw_hole_max_diameter)/2-tool_holder_extra_width,
        (screw_hole_max_diameter)/2,
        0
    ]) cylindered_cube(
        tool_holder_extra_width*2+screw_hole_gap,
        tool_holder_depth,
        tool_holder_height,
        tool_holder_corner_rounding
    );
}

module tool_holder_inner() {
    translate([
        (screw_hole_max_diameter)/2-tool_holder_extra_width+wall_thickness,
        (screw_hole_max_diameter)/2+wall_thickness,
        wall_thickness
    ]) rounded_cube(
        tool_holder_extra_width*2+screw_hole_gap-wall_thickness*2,
        tool_holder_depth-wall_thickness*2,
        tool_holder_height,
        tool_holder_corner_rounding-wall_thickness/2
    );
}

union() {
    tall_nubs();
    difference() {
        tool_holder_outer();
        tool_holder_inner();
        tool_holder_cutter((screw_hole_max_diameter)/2-tool_holder_extra_width, (screw_hole_max_diameter)/2);
    }
}

//tool_holder_cutter((screw_hole_max_diameter)/2-tool_holder_extra_width, (screw_hole_max_diameter)/2);