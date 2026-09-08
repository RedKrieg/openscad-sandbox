$fs=0.2;
$fa=0.5;
board_width=21.2;
board_length=52;
board_height=1.3;
component_height=2.0; //back of board
wall_thickness=1.2;
clearance=0.2;
lip_width=1;
magnet_diameter=15.2;
magnet_height=1.8;
layer_height=0.2;
rounding=0.4;
retaining_nub_diameter=0.8;
retaining_nub_offset=1.9;

module rounded_cube(dims, rounding) {
    hull() for(
        x=[rounding, dims.x-rounding],
        y=[rounding, dims.y-rounding],
        z=[rounding, dims.z-rounding]
    ) {
        translate([x, y, z]) sphere(r=rounding);
    }
}

module component_cutout() {
    translate([
        wall_thickness+lip_width,
        wall_thickness+lip_width,
        magnet_height+layer_height*2
    ]) cube([
        board_length*2-lip_width*2,
        board_width-lip_width*2,
        board_height+wall_thickness+component_height
    ]);
}

module board_cutout() {
    difference() {
        translate([
            wall_thickness,
            wall_thickness,
            magnet_height+layer_height*2+component_height
        ]) cube([
            board_length*2+wall_thickness*2,
            board_width,
            board_height
        ], rounding);
        for(y=[-clearance, board_width+clearance])translate([
            wall_thickness+retaining_nub_offset+retaining_nub_diameter/2,
            wall_thickness+y,
            magnet_height+layer_height*2+component_height
        ]) cylinder(
            h=board_height,
            d=retaining_nub_diameter
        );
    }
}


module shell() {
    rounded_cube([
        wall_thickness*2+board_length,
        wall_thickness*2+board_width,
        board_height+magnet_height+layer_height*2+component_height+wall_thickness
    ], rounding);
}

module magnet_cutout() {
    translate([
        board_length/2+wall_thickness,
        board_width/2+wall_thickness,
        0
    ]) cylinder(
        h=magnet_height,
        d=magnet_diameter
    );
}

difference() {
    shell();
    board_cutout();
    component_cutout();
    magnet_cutout();
}
//magnet_cutout();