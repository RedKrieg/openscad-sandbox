container_width = 150;
container_height = 150;

paint_bottle_radius = 12.75;
surface_thickness = 1.6;

brace_width = 4;

//separate them by twice the surface thickness
min_separation = (paint_bottle_radius + surface_thickness) * 2;

count_wide = floor(container_width / min_separation);
count_high = floor(container_height / min_separation);

sep_wide = container_width / count_wide;
sep_high = container_height / count_high;
sep = min(sep_wide, sep_high);

//creates a beveled cutout centered on the origin
module cutout(r, h) {
    rotate_extrude() difference() {
        translate([0, -h]) square([r+h/2, h*2]);
        //divide $fn by 4 for reasonable resolution on the toroid
        translate([r+h/2, 0]) circle(h/2, $fn=$fn/4);
    }
}

module cutout_array_square() {
    for(x=[0:count_wide-1]) {
        for(y=[0:count_high-1]) {
            translate([x*sep+sep/2, y*sep+sep/2, 0]) cutout(paint_bottle_radius, surface_thickness);
        }
    }
}

module part_array() {
    sep_offset_x = sep * cos(30);
    sep_offset_y = sep * sin(60);
    //figure out how much space we take up
    new_count_high = floor(container_height / sep_offset_y);
    //set an offset to center the array horizontally
    base_offset_x = sep/2;
    //set an offset to center the array vertically
    base_offset_y = 3*container_height/new_count_high/4;
    for(y=[0:new_count_high-1]) {
        for(x=[0:count_wide-1-abs(y%2)]) {
            //x steps are sep, y steps are sep offset
            translate([x*sep+base_offset_x+abs(y%2)*sep/2, y*sep_offset_y+base_offset_y, 0]) children();
        }
    }
}

module cutout_array_hex() {
    part_array() cutout(paint_bottle_radius, surface_thickness);
}

module cross_brace() {
    for(theta=[-60, 60]) {
        rotate([0, 0, theta]) {
            translate([(sep-surface_thickness)/2, -brace_width/2, 0]) cube([surface_thickness, brace_width, paint_bottle_radius*2]);
            translate([-(sep+surface_thickness)/2, -brace_width/2, 0]) cube([surface_thickness, brace_width, paint_bottle_radius*2]);
            translate([-(sep+surface_thickness)/2, -brace_width/2, paint_bottle_radius*2]) cube([sep+surface_thickness, brace_width, surface_thickness]);
        }
    }
}

module rounded_sheet(x, y, h, r) {
    render() hull() {
        for(p_x=[0+r, x-r]) {
            for(p_y=[0+r, y-r]) {
                translate([p_x, p_y, 0]) rotate_extrude() translate([r-h/2, 0]) circle(h/2, $fn=$fn/4);
            }
        }
    }
}

module bottle_array() {
    difference() {
        rounded_sheet(container_width, container_height, surface_thickness, paint_bottle_radius+surface_thickness);
        cutout_array_hex();
    }
}

part_array() cross_brace();
bottle_array($fn=48);