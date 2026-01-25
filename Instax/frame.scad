$fa = 0.2;
$fs = 0.2;
layer_height = 0.2;

instax_outer = [86, 54];
instax_inner = [62, 46];
instax_lower_offset = 16.25;
instax_thickness = 1.0;

wall_thickness = 2.2;

magnet_radius = 3.05;
magnet_height = 2.0;

module magnet_shell() {
    cylinder(h=magnet_height+layer_height*2, r=magnet_radius+wall_thickness);
}

module magnet_pocket() {
    translate([0, 0, layer_height*2]) cylinder(h=magnet_height, r=magnet_radius);
}

module frame_corner() {
    radius = magnet_radius+wall_thickness;
    translate([0, 0, wall_thickness]) difference() {
        scale([1, 1, wall_thickness / radius]) sphere(r=radius);
        cylinder(h=radius, r=radius);
    }
}

module frame_face() {
    hull()
        for (x=[0, instax_outer.x], y=[0, instax_outer.y])
        translate([x, y, 0]) frame_corner();
}

module frame_back() {
    difference() {
        union() {
            difference() {
                hull()
                    for (x=[0, instax_outer.x], y=[0, instax_outer.y])
                        translate([x, y, wall_thickness]) magnet_shell();
                frame_inner(h=wall_thickness+instax_thickness+layer_height*4);
            }
            for (x=[0, instax_outer.x], y=[0, instax_outer.y]) {
                translate([x, y, wall_thickness]) magnet_shell();
                intersection() {
                    cube([instax_outer.x, instax_outer.y, wall_thickness+magnet_height+layer_height*2]);
                    translate([x, y, wall_thickness]) rotate(45) linear_extrude(magnet_height+layer_height*2) square((magnet_radius+wall_thickness)*2, center=true);
                }
            }
        }
        for (x=[0, instax_outer.x], y=[0, instax_outer.y])
                translate([x, y, wall_thickness]) magnet_pocket();
    }
}

module frame_outer() {
    union() {
        frame_face();
        frame_back();
    }
}

module frame_inner(h=instax_thickness) {
    translate([0, 0, wall_thickness-instax_thickness]) linear_extrude(h) square(instax_outer);
}

module viewport() {
    translate([instax_lower_offset, (instax_outer.y-instax_inner.y)/2, 0]) linear_extrude(wall_thickness) square(instax_inner);
}
/*
for (x=[0, instax_outer.x], y=[0, instax_outer.y])
    translate([x, y, wall_thickness]) magnet_pocket();
*/
difference() {
    frame_outer();
    frame_inner();
    viewport();
}
