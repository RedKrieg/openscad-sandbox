$fs=0.2;
$fa=1;
strut_base_length=100;
slot_length=5;
diameter=15;
wall_thickness=3;
slot_width=2;
slot_count=3;
cap_length=2;
cap_plug_length=1.8;
cap_clearance=0.05;

module slot_cutter_cylinder() {
    rotate([-90, 0, 0]) cylinder(h=diameter, d=slot_width);
}

module slot_cutter_fin() {
    hull() {
        slot_cutter_cylinder();
        translate([0, 0, slot_length]) slot_cutter_cylinder();
    }
}

module slot_cutter() {
    for(angle=[360/slot_count:360/slot_count:360]) {
        rotate([0, 0, angle]) slot_cutter_fin();
    }
}

module hex_shell() {
    difference() {
        cylinder(h=strut_base_length+slot_length*2, d=diameter, $fn=6);
        cylinder(h=strut_base_length+slot_length*2, d=diameter-wall_thickness*2);
    }
}

module strut() {
    difference() {
        hex_shell();
        slot_cutter();
        translate([0, 0, strut_base_length+slot_length]) slot_cutter();
    }
}

module cap() {
    cylinder(h=cap_length, d=diameter, $fn=6);
    cylinder(h=cap_length+cap_plug_length, d=diameter-wall_thickness*2-cap_clearance);
}

strut();
//cap();