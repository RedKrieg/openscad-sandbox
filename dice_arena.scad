column_size=6.3;
column_gap=62;
column_height=30;
base_height=6;
fence_size=5.5;
fence_height=28;
strut_width=5;
strut_twist=360;
strut_complexity=6;
base_radius=75;
$fn=100;

module gate() {
    union() {
        translate([column_gap/2, 0, 0]) cube([column_size, column_size, base_height+column_height]);
        translate([-column_gap/2-column_size, 0, 0]) cube([column_size, column_size, base_height+column_height]);
        translate([-column_gap/2-column_size, column_size, 0]) cube([column_gap+column_size*2, column_gap, base_height]);
        translate([-column_gap/2-fence_size-(column_size-fence_size)/2, column_size, base_height+fence_height-fence_size]) cube([fence_size, column_gap, fence_size]);
        translate([column_gap/2+(column_size-fence_size)/2, column_size, base_height+fence_height-fence_size]) cube([fence_size, column_gap, fence_size]);
        //blocker for keeping the gap open
        translate([-column_gap/2-fence_size,0,base_height]) cube([column_gap+fence_size*2, column_gap, fence_height+fence_size]);
    }
}

module base() {
    cylinder(r1=base_radius, r2=base_radius, h=base_height);
}

module fence() {
    union() {
        //rails
        translate([0, 0, base_height+fence_height-fence_size]) difference() {
            cylinder(r1=base_radius-(column_size-fence_size)/2, r2=base_radius-(column_size-fence_size)/2, h=fence_size);
            cylinder(r1=base_radius-(column_size-fence_size)/2-fence_size, r2=base_radius-(column_size-fence_size)/2-fence_size, h=fence_size);
        }
        //under-rail support
        translate([0,0,fence_height+base_height-fence_size]) rotate_extrude(angle=360) translate([base_radius-fence_size/2-(column_size-fence_size)/2,0,0]) circle(r=fence_size/2, $fn=4);
        //columns
        for (deg=[0:30:360]) {
            //skip columns in gap
            if (deg>30 && deg<330) {
                rotate([0, 0, deg]) translate([-column_size/2, base_radius-column_size]) cube([column_size, column_size, column_height+base_height]);
            }
        }
        //bars
        for (deg=[0:6:360]) {
            //skip bars in gap
            if (deg>30 && deg<330) {
                rotate([0, 0, deg]) translate([0, base_radius-strut_width/2-(column_size-strut_width)/2, base_height]) union() {
                    //cylinder(r1=strut_width/2, r2=strut_width/2, h=fence_height, $fn=32);
                    linear_extrude(height=fence_height, twist=strut_twist) circle(r=strut_width/2, $fn=strut_complexity);
                    linear_extrude(height=fence_height, twist=-strut_twist) circle(r=strut_width/2, $fn=strut_complexity);
                }
            }
        }
    }
}

module arena() {
    difference() {
        union() {
            base();
            fence();
        }
        translate([0, sqrt(base_radius*base_radius-(column_gap/2+column_size)*(column_gap/2+column_size))-column_size, 0]) gate();
    }
}

//gate();
arena();
//fence();
