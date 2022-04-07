bowl_diameter = 97;
bowl_height = 35;

stick_diameter_min = 4;
stick_diameter_max = 6;
stick_taper_length = 70;
spoon_handle_width = 8;
spoon_handle_height = 4;
tamper_base_radius = 24;
tamper_base_height = 5.5;
tamper_handle_radius = 3.5;
tamper_handle_height = 45;

wall_thickness_min = 2;

shell_arc_degrees = 120;

bowl_radius = bowl_diameter/2;
shell_radius=stick_diameter_max/2+wall_thickness_min*2;
shell_arc_offset = (180-shell_arc_degrees)/2;

$fn=101;

module bowl_cutout()
{
    cylinder(h=bowl_height, r=bowl_radius);
}

module stick_cutout()
{
    union() {
        cylinder(h=stick_taper_length, r1=stick_diameter_min/2, r2=stick_diameter_max/2);
        translate([0, 0, bowl_height-wall_thickness_min*2]) cylinder(h=wall_thickness_min*2, r1=0, r2=stick_diameter_max/2+wall_thickness_min);
    }
}

module spoon_cutout()
{
    union()
    {
        translate([-spoon_handle_width/2, -spoon_handle_height/2, 0]) cube([spoon_handle_width, spoon_handle_height, bowl_height]);
        translate([0, 0, bowl_height-wall_thickness_min*2]) cylinder(h=wall_thickness_min*2, r1=0, r2=stick_diameter_max/2+wall_thickness_min);
    }
}

module tamper_cutout()
{
    union()
    {
        cylinder(h=tamper_base_height, r=tamper_base_radius);
        translate([0, 0, tamper_base_height]) cylinder(h=tamper_handle_height, r=tamper_handle_radius);
    }
}

module shell()
{
    linear_extrude(bowl_height) union()
    {
        intersection()
        {
            difference()
            {
                circle(bowl_radius+shell_radius*2);
                circle(bowl_radius);
                translate([-bowl_radius-shell_radius*2, -bowl_radius-shell_radius*2]) square([(bowl_radius+shell_radius*2)*2, bowl_radius+shell_radius*2]);
            }
            polygon([
                [0, 0],
                [-bowl_radius*2*cos(shell_arc_offset), bowl_radius*2*sin(shell_arc_offset)],
                [0, bowl_radius*2],
                [bowl_radius*2*cos(shell_arc_offset), bowl_radius*2*sin(shell_arc_offset)]
            ]);
        }
        rotate([0, 0, shell_arc_offset]) translate([bowl_radius+shell_radius, 0]) circle(shell_radius);
        rotate([0, 0, shell_arc_offset+shell_arc_degrees]) translate([bowl_radius+shell_radius, 0]) circle(shell_radius);
    }
}

module incense_rack()
{
    difference()
    {
        shell();
        rotate([0, 0, 127]) translate([bowl_radius+shell_radius, 0, 0]) stick_cutout();
        rotate([0, 0, 150]) translate([bowl_radius+shell_radius, 0, 0]) stick_cutout();
        translate([0, bowl_radius+shell_radius, 0]) spoon_cutout();
        rotate([0, 0, 53]) translate([bowl_radius+shell_radius-tamper_base_height, 0, bowl_height]) rotate([0, 90, 0]) tamper_cutout();
    }
}

incense_rack();

