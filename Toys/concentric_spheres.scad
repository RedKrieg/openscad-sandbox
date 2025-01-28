use <geodesic_sphere.scad>
shell_thickness = 2.6;
shell_gap = 0.25;
core_radius = 12.7;
shell_count = 7;
cut_thickness = 4*core_radius/3;
$fs=0.8;
$fa=1.2;

intersection() {
    cylinder(h=cut_thickness, r=core_radius+(shell_thickness+shell_gap)*shell_count, center=true);
    union() {
        geodesic_sphere(r=core_radius);
        for (i=[0:shell_count]) {
            difference() {
                geodesic_sphere(r=core_radius+(shell_thickness+shell_gap)*i);
                geodesic_sphere(r=core_radius+(shell_thickness+shell_gap)*i-shell_thickness);
            }
        }
    }
}