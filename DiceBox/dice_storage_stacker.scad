//which object should be rendered
render_object = "lid"; //[die, figure, lid, pads]
//if rendering lid, which design to put on it
lid_design = "dnd"; //[none, dnd, cr, web, text]
//text to put on lid
lid_text = "BEEG Dice";
//font for lid text
lid_text_font = "Fira Sans:style=Regular";
//scale text to fit lid
lid_text_scale = 1.3; //[0.1:0.1:8]
//depth of logo when using a lid design
logo_depth = 0.3; //[0.1:0.1:1.0]
//actual largest distance between two points on a set of 7 rpg dice (12.2mm measured, 14.6 jumbo)
die_radius_inner = 13.6; //[0.1:0.1:15]
die_radius = die_radius_inner/cos(30);
//height of tallest die when lying flat in pocket (21mm measured, 25 jumbo, 26 metal)
die_pocket_height = 26; //[0.1:0.1:30]
//height of figure when lying flat in pocket
figure_pocket_height = 26; //[0.1:0.1:40]
//wall thickness between cells
wall_thickness = 1.6; //[0.1:0.1:3.0]
die_tray_depth = die_pocket_height + wall_thickness;
figure_tray_depth = figure_pocket_height + wall_thickness;
//connection clip height
connector_height = 2.0; //[0.1:0.1:5]
//connection clip width at top
connector_width_top = 5; //[0.1:0.1:5]
//connection clip width at bottom
connector_width_bottom = 4; //[0.1:0.1:5]
//extra space to make for an easier fit when clipping together
connector_gap_offset = 0.20; //[0.05:0.05:0.5]
//length of tongue/groove around the outside in degrees
connector_degrees = 10; //[6:0.5:18]
//number of connectors
connector_count = 3; //[0, 2, 3, 6]
//whether to use a rounded shell
shell_style = "rounded"; //[rounded, cylinder, secant]
//for rounded shells, how far it should expand
shell_expansion = 0.6; //[0.1:0.1:5]
//number of grip gaps in shell
shell_grip_count = 18; //[6, 12, 18, 24, 30, 36, 60, 72, 90]
//number of shell_expansion radii to widen groove
shell_grip_ratio = 10;
//what type of grip pattern should be used
grip_style = "helical"; //[vertical, helical]
//how much to slant helical grooves, related to shell_grip_count
grip_helix_offset = render_object=="lid" ? 1 : 4; //[1:1:6]
//radius of the magnet
magnet_radius = 3.05;
//height of the magnet
magnet_height = 2.1;
//resolution, higher numbers render slower.  primes seem to help slicers?
//$fn = 101;
$fa = 360/101;
$fs = 0.2;

//reusable math
shell_radius = (die_radius_inner+wall_thickness)*3;
connector_top_outer_radius = shell_radius - wall_thickness * 2; //extra distance from outer wall
connector_top_inner_radius = connector_top_outer_radius - connector_width_top;
connector_bottom_outer_radius = shell_radius-wall_thickness*2-(connector_width_top-connector_width_bottom)/2;
connector_bottom_inner_radius = connector_bottom_outer_radius-connector_width_bottom;
//distance from center to center of magnet
magnet_distance = shell_radius-wall_thickness-magnet_radius;

module pits(depth) {
    union() {
        translate([0, 0, wall_thickness]) cylinder(h=depth-wall_thickness, r=die_radius, $fn=6);
        step = 360/6;
        for (theta=[step:step:360]) {
            rotate([0, 0, theta]) translate([0, die_radius_inner*2+wall_thickness, wall_thickness]) cylinder(h=depth-wall_thickness, r=die_radius, $fn=6);
        }
    }
}

module shell_rounded(h, circle_radius) {
    if (render_object != "lid") {
        h2 = h/4;
        new_circle_radius = (h2*h2/4/shell_expansion+shell_expansion)/2;
        union() {
            shell_secant(h/4, new_circle_radius);
            translate([0, 0, 3*h/4]) shell_secant(h/4, new_circle_radius);
            translate([0, 0, h/8]) cylinder(r=shell_radius+shell_expansion, h=3*h/4);
        }
    } else {
        shell_secant(h, circle_radius);
    }
    /*
    rotate_extrude() union() {
        translate([shell_radius, h-shell_expansion]) circle(r=shell_expansion);
        square([shell_radius, h]);
        translate([shell_radius, shell_expansion]) square([shell_expansion, h-2*shell_expansion]);
        translate([shell_radius, shell_expansion]) circle(r=shell_expansion);
    }*/
}

module shell_secant(h, circle_radius) {
    difference() {
        //start the drawing centered on the origin to simplify the outer wall geometry calculations, move up to z>=0 after
        translate([0, 0, h/2]) union() {
            cylinder(h=h, r=shell_radius, center=true);
            //create a toroid with the correct radius for the outside wall
            rotate_extrude() difference() {
                translate([shell_radius-circle_radius+shell_expansion, 0, 0]) circle(r=circle_radius);
                //this square is oversized by design.  it removes all possible negative values before performing the rotate_extrude operation
                translate([-(circle_radius*circle_radius), 0]) square(circle_radius*circle_radius*2, center=true);
            }
        }
    }
}

module shell(h) {
    if (shell_style == "cylinder")
    {
        cylinder(h=h, r=shell_radius);
    } else {
        //Ptolemy's Theorem solved for shell_expansion
        circle_radius = (h*h/4/shell_expansion+shell_expansion)/2;
        difference() {
            //base shell style
            if (shell_style == "rounded") {
                shell_rounded(h, circle_radius);
            } else {
                shell_secant(h, circle_radius);
            }
            //cut off any excess toroid
            translate([0, 0, h]) cylinder(h=circle_radius*2, r=shell_radius+circle_radius);
            translate([0, 0, -circle_radius*2]) cylinder(h=circle_radius*2, r=shell_radius+circle_radius);
            //add grip cutouts
            if (grip_style == "vertical") {
                step = 360/shell_grip_count;
                //really wish openscad used < rather than <= for ranges, this doesn't work if (360 % shell_grip_count > 0)
                for (theta=[step:step:360]) {
                    rotate([0, 0, theta]) translate([0, shell_radius+shell_expansion*shell_grip_ratio, 0]) cylinder(h=h, r=shell_expansion*shell_grip_ratio);
                }
            } else if (grip_style == "helical") {
                step = 360/shell_grip_count;
                for (theta=[step:step:360]) {
                    union() {
                        rotate([0, 0, theta]) linear_extrude(height=h, twist=step*grip_helix_offset) translate([0, shell_radius+shell_expansion*shell_grip_ratio, 0]) circle(r=shell_expansion*shell_grip_ratio);
                        rotate([0, 0, theta]) linear_extrude(height=h, twist=-step*grip_helix_offset) translate([0, shell_radius+shell_expansion*shell_grip_ratio, 0]) circle(r=shell_expansion*shell_grip_ratio);
                    }
                }
            }
        }
    }
}

module connector_base(gap_offset) {
    difference() {
        cylinder(h=connector_height+gap_offset*2, r1=connector_bottom_outer_radius+gap_offset, r2=connector_top_outer_radius+gap_offset);
        cylinder(h=connector_height+gap_offset*2, r1=connector_bottom_inner_radius-gap_offset, r2=connector_top_inner_radius-gap_offset);
    }
}

module wedge(h, r, theta, wedge_scale=1) {
    wedge_vectors = [[0, 0], [r, 0], [r*cos(theta), r*sin(theta)]];
    wedge_center = [(r+r*cos(theta))/3, r*sin(theta)/3];
    translate(wedge_center) linear_extrude(height=h, scale=wedge_scale) translate(-wedge_center) polygon(wedge_vectors);
}

module connector_tongue() {
    mirror([0, 1, 0]) difference() {
        connector_base(0);
        step = 360/connector_count;
        for (theta=[step:step:360]) {
            rotate([0, 0, theta]) wedge(h=connector_height, r=connector_top_outer_radius*2, theta=step-connector_degrees, wedge_scale=1.05);
        }
    }
}

module connector_groove() {
    union() {
        //sloped part
        mirror([0, 1, 0]) difference() {
            connector_base(connector_gap_offset);
            step = 360/connector_count;
            for (theta=[step:step:360]) {
                rotate([0, 0, theta]) wedge(h=connector_height+connector_gap_offset*2, r=connector_top_outer_radius*2, theta=step-connector_degrees);
            }
        }
        //open part
        difference() {
            cylinder(h=connector_height+connector_gap_offset*2, r1=connector_top_outer_radius+connector_gap_offset*2, r2=connector_top_outer_radius+connector_gap_offset);
            cylinder(h=connector_height+connector_gap_offset*2, r1=connector_top_inner_radius-connector_gap_offset*2, r2=connector_top_inner_radius-connector_gap_offset);
            step = 360/connector_count;
            for (theta=[step:step:360]) {
                //fudge factor to fix 0 width wall between gaps
                rotate([0, 0, theta+0.01]) wedge(h=connector_height+connector_gap_offset*2, r=connector_top_outer_radius*2, theta=step-connector_degrees-0.5, wedge_scale=1);
            }
        }
    }
}

module magnet() {
    cylinder(h=magnet_height, r=magnet_radius);
}

module magnet_array() {
    step = 360/3;
    offset = step/2;
    for (theta=[offset:step:360]) {
        rotate([0, 0, theta]) translate([magnet_distance, 0, 0]) magnet();
    }
}

module die_tray(depth) {
    union() {
        difference() {
            shell(h=depth);
            pits(depth);
            connector_groove();
            magnet_array();
            translate([0, 0, depth]) mirror([0, 0, 1]) magnet_array();
        }
        translate([0, 0, depth]) connector_tongue();
    }
}

module figure_tray(depth) {
    difference() {
        die_tray(depth);
        translate([0, 0, wall_thickness]) cylinder(h=figure_pocket_height, r=die_radius*2+wall_thickness);
    }
}

// SVG NOT INCLUDED FOR LICENSING REASONS
module dnd_logo(h) {
    sf = 0.2;
    translate([0, 0, h]) mirror([0, 0, 1]) linear_extrude(height=logo_depth) scale([sf, sf]) import("dnd_logo.svg", center=true);
}

// SVG NOT INCLUDED FOR LICENSING REASONS
module cr_logo(h) {
    sf = 1.1;
    translate([0, 0, h]) mirror([0, 0, 1]) linear_extrude(height=logo_depth) scale([sf, sf]) import("critical_role.svg", center=true);
}

// SVG NOT INCLUDED FOR LICENSING REASONS
module web_logo(h) {
    sf = 0.26;
    translate([-2.0, -1.0, h]) mirror([0, 0, 1]) linear_extrude(height=logo_depth) scale([sf, sf]) import("spider_web.svg", center=true);
}

// SVG NOT INCLUDED FOR LICENSING REASONS
module lovesnake_logo(h) {
    sf = 0.28;
    translate([0, 0, h]) mirror([0, 0, 1]) linear_extrude(height=logo_depth) scale([sf, sf]) import("love_snake.svg", center=true);
}

// SVG NOT INCLUDED FOR LICENSING REASONS
module dragonmark_logo(h) {
    sf = 0.45;
    translate([0, 0, h]) mirror([0, 0, 1]) linear_extrude(height=logo_depth) scale([sf, sf]) import("dragonmark.svg", center=true);
}

// SVG NOT INCLUDED FOR LICENSING REASONS
module tentacle_logo(h) {
    sf = 0.50;
    translate([0, 0, h]) mirror([0, 0, 1]) linear_extrude(height=logo_depth) scale([sf, sf]) import("tentacle.svg", center=true);
}

// SVG NOT INCLUDED FOR LICENSING REASONS
module krullglaive_logo(h) {
    sf = 0.90;
    translate([-0.5, 2.95, h]) mirror([0, 0, 1]) linear_extrude(height=logo_depth) scale([sf, sf]) import("krullglaive.svg", center=true);
}

// SVG NOT INCLUDED FOR LICENSING REASONS
module jupiter_logo(h) {
    sf = 0.345;
    translate([0, 0, h]) mirror([0, 0, 1]) linear_extrude(height=logo_depth) scale([sf, sf]) import("jupiter.svg", center=true);
}

module beeg_logo(h) {
    sf = 0.62;
    translate([-1, 0, h]) mirror([0, 0, 1]) linear_extrude(height=logo_depth) scale([sf, sf]) import("beegdice.svg", center=true);
}

module scratch_logo(h) {
    sf = 2.85;
    translate([10, 0, h]) mirror([0, 0, 1]) linear_extrude(height=logo_depth) scale([sf, sf]) import("Dlogo.svg", center=true);
}

module lid_text(h) {
    sf = lid_text_scale;
    translate([0, 0, h]) mirror([0, 0, 1]) linear_extrude(height=logo_depth) scale([sf, sf]) text(text=lid_text, font=lid_text_font, halign="center", valign="center");
}

module lid(h) {
    difference() {
        shell(h);
        connector_groove();
        magnet_array();
        if (lid_design=="dnd") {
            dnd_logo(h);
        } else if (lid_design=="cr") {
            cr_logo(h);
        } else if (lid_design=="text") {
            lid_text(h);
        } else if (lid_design=="web") {
            web_logo(h);
        } else if (lid_design=="lovesnake") {
            lovesnake_logo(h);
        } else if (lid_design=="dragonmark") {
            dragonmark_logo(h);
        } else if (lid_design=="tentacle") {
            tentacle_logo(h);
        } else if (lid_design=="krullglaive") {
            krullglaive_logo(h);
        } else if (lid_design=="jupiter") {
            jupiter_logo(h);
        } else if (lid_design=="beeg") {
            beeg_logo(h);
        } else if (lid_design=="scratch") {
            scratch_logo(h);
        }
    }
}

if (render_object == "die") {
    die_tray(die_tray_depth);
} else if (render_object == "figure") {
    figure_tray(figure_tray_depth);
} else if (render_object == "lid") {
    lid(die_tray_depth/4);
} else {
    pits(0.6+wall_thickness);
}
