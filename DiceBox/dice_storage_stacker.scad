//which object should be rendered
render_object = "lid"; //[die, figure, lid]
//if rendering lid, which design ot put on it
lid_design = "dnd"; //[none, dnd, cr, web, text]
//text to put on lid
lid_text = "D&D";
//font for lid text
lid_text_font = "MagicMedieval";
//scale text to fit lid
lid_text_scale = 2.0; //[0.1:0.1:8]
//depth of logo when using a lid design
logo_depth = 0.3; //[0.1:0.1:1.0]
//actual largest distance between two points on a set of 7 rpg dice
die_radius_inner = 12.2; //[0.1:0.1:15]
die_radius = die_radius_inner/cos(30);
//height of tallest die when lying flat in pocket
die_pocket_height = 21; //[0.1:0.1:30]
//height of figure when lying flat in pocket
figure_pocket_height = 26; //[0.1:0.1:40]
//wall thickness between cells
wall_thickness = 1.6; //[0.1:0.1:3.0]
die_tray_depth = die_pocket_height + wall_thickness;
figure_tray_depth = figure_pocket_height + wall_thickness;
//connection clip height
connector_height = 2.0; //[0.1:0.1:5]
//connection clip width at top
connector_width_top = 4; //[0.1:0.1:5]
//connection clip width at bottom
connector_width_bottom = 3; //[0.1:0.1:5]
//extra space to make for an easier fit when clipping together
connector_gap_offset = 0.1; //[0.05:0.05:0.5]
//whether to use a rounded shell
shell_style = "rounded"; //[rounded, cylinder]
//for rounded shells, how far it should expand
shell_expansion = 0.6; //[0.1:0.1:5]
//number of grip gaps in shell
shell_grip_count = 18; //[6, 12, 18, 24, 30, 36, 60, 72, 90]
//number of shell_expansion radii to widen groove
shell_grip_ratio = 10;
//what type of grip pattern should be used
grip_style = "helical"; //[vertical, helical]
//how much to slant helical grooves, related to shell_grip_count
grip_helix_offset = 1; //[1:1:6]
//resolution, higher numbers render slower.  primes seem to help slicers?
$fn = 101;

//reusable math
shell_radius = (die_radius_inner+wall_thickness)*3;
connector_top_outer_radius = shell_radius-wall_thickness;
connector_top_inner_radius = connector_top_outer_radius - connector_width_top;
connector_bottom_outer_radius = shell_radius-wall_thickness-(connector_width_top-connector_width_bottom)/2;
connector_bottom_inner_radius = connector_bottom_outer_radius-connector_width_bottom;

module pits(depth) {
    union() {
        translate([0, 0, wall_thickness]) cylinder(h=depth-wall_thickness, r=die_radius, $fn=6);
        step = 360/6;
        for (theta=[step:step:360]) {
            rotate([0, 0, theta]) translate([0, die_radius_inner*2+wall_thickness, wall_thickness]) cylinder(h=depth-wall_thickness, r=die_radius, $fn=6);
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

module wedge(h, r, theta, scale=1) {
    wedge_vectors = [[0, 0], [r, 0], [r*cos(theta), r*sin(theta)]];
    wedge_center = [(r+r*cos(theta))/3, r*sin(theta)/3];
    translate(wedge_center) linear_extrude(height=h, scale=scale) translate(-wedge_center) polygon(wedge_vectors);
}

module connector_tongue() {
    mirror([0, 1, 0]) difference() {
        connector_base(0);
        step = 360/6;
        for (theta=[step:step:360]) {
            rotate([0, 0, theta]) wedge(h=connector_height, r=connector_top_outer_radius*2, theta=step/1.25, scale=1.05);
        }
    }
}

module connector_groove() {
    union() {
        //sloped part
        mirror([0, 1, 0]) difference() {
            connector_base(connector_gap_offset);
            step = 360/6;
            for (theta=[step:step:360]) {
                rotate([0, 0, theta]) wedge(h=connector_height+connector_gap_offset, r=connector_top_outer_radius*2, theta=step/1.25);
            }
        }
        //open part
        difference() {
            cylinder(h=connector_height+connector_gap_offset, r1=connector_top_outer_radius+connector_gap_offset*2, r2=connector_top_outer_radius+connector_gap_offset);
            cylinder(h=connector_height+connector_gap_offset, r1=connector_top_inner_radius-connector_gap_offset*2, r2=connector_top_inner_radius-connector_gap_offset);
            step = 360/6;
            for (theta=[step:step:360]) {
                //fudge factor to fix 0 width wall between gaps
                rotate([0, 0, theta+0.01]) wedge(h=connector_height+connector_gap_offset, r=connector_top_outer_radius*2, theta=step/1.26);
            }
        }
    }
}

module die_tray(depth) {
    union() {
        difference() {
            shell(h=depth);
            pits(depth);
            connector_groove();
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
    sf = 0.18;
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

module lid_text(h) {
    sf = lid_text_scale;
    translate([0, 0, h]) mirror([0, 0, 1]) linear_extrude(height=logo_depth) scale([sf, sf]) text(text=lid_text, font=lid_text_font, halign="center", valign="center");
}

module lid(h) {
    difference() {
        shell(h);
        connector_groove();
        if (lid_design=="dnd") {
            dnd_logo(h);
        } else if (lid_design=="cr") {
            cr_logo(h);
        } else if (lid_design=="text") {
            lid_text(h);
        } else if (lid_design=="web") {
            web_logo(h);
        }
    }
}

if (render_object == "die") {
    die_tray(die_tray_depth);
} else if (render_object == "figure") {
    figure_tray(figure_tray_depth);
} else {
    lid(die_tray_depth/4);
}