// geodesic sphere from https://www.thingiverse.com/thing:1484333
use <geodesic_sphere.scad>;

wall_height_inner = 55;
wall_height_outer = 90;

slot_depth = 14;
slot_height = 16;

surface_to_slot = 21;

slot_depth_outer = 30;

extrude_thickness = slot_height;
chamfer_depth = 7.75;

min_thickness = 8;
min_thickness_45 = min_thickness*sqrt(2);

strut_thickness = 8; //old min_thickness, need to rename for not to have break stuff and for more accurate

rounding_radius = 1.4;

magnet_diameter = 12.2;
magnet_height = 5;

hole_diameter = 3.3; //#6x0.5"
hole_depth = 9; //#6x0.5" 9mm protrudes beyond magnet
/*
hole_diameter = 2.7; //M3x16
hole_depth = 20; //M3x16
*/

tablet_contact_hypotenuse = 100;
tablet_depth = 20;
tablet_angle = 15;
tablet_lip = 8;

text_depth = 0.3;
text_size = slot_height/4;
text_font = "Ubuntu:style=Bold";//"DejaVu Sans:style=Bold";
//this 1.83 here sucks, can't figure out which of my measurements is off.  angle is not exactly 15 degrees on the back surface
text_fudge = [-2, 0, 1.83];
//same for the 0.21 degree offset here
text_rotation = [90, 0, 180-tablet_angle-0.21];

$fn = $preview ? 12 : 48;

edge_depth = slot_depth-slot_depth_outer-surface_to_slot+chamfer_depth;

//normalize a vector (length to 1)
function normalize(v) = v / norm(v);

//dot product of two vectors
function dot(v1, v2) = v1.x*v2.x + v1.y*v2.y;

//midpoint between two points
function midpoint(p1, p2) = (p1 + p2) / 2;

//6 points of distance [gap]/2 and [gap] from p1/p2 and [gap]/2 from the midpoint
//these are used to determine distance from the corners for preserving strut thickness
function critical_points(p1, p2, gap) = let(
    mp = midpoint(p1, p2),
    v_p = normalize(p1 - mp) * gap / 2
) [p1-v_p/2, p1-v_p, mp+v_p, mp-v_p, p2+v_p, p2+v_p/2];

function get_strut_points(p1, p2, p3, gap) = let(
    v0 = critical_points(p2, p1, gap),
    v1 = critical_points(p2, p3, gap)
    ) [v0[0], v1[0]];

//Find the center point of a circle of radius `r` that is tangent to both segments p2 -> p1 and p2 -> p3
function get_curve_center(p1, p2, p3, r, convex=true) =
    let(
        // Vector should point outside the curve for concave angles
        convexity = convex ? 1 : -1,
        // Calculate vectors for the two line segments
        v1 = p1 - p2,
        v2 = p3 - p2,
        // Calculate the angle between the two line segments
        angle = acos(dot(v1, v2)/(norm(v1)*norm(v2))),
        // Calculate the projection of p2 onto the bisector of the two line segments
        v_center = normalize(normalize(v1) + normalize(v2)),
        center = p2 + r / sin(angle/2) * v_center * convexity
    ) center;

//Return a list of the center points of all circles that should be hulled to create a curved polygon of radius `r` matching `points`
function get_curve_centers(points, r, convexities) = [
    for(i = [0:len(points)-1]) let(
        prev_idx = (i - 1 + len(points)) % len(points),
        curr_idx = i,
        next_idx = (i + 1) % len(points)
    ) get_curve_center(points[prev_idx], points[curr_idx], points[next_idx], r, convexities[i])
];
    
//Extrude a box of height `h` with profile `points` and rounded by `r`
module rounded_extrude(h, points, r, twist=0) {
    // we treat all input to this function as a convex polygon
    convexities = [ for(points) true ];
    hull() for(p=get_curve_centers(points, r, convexities)) {
        translate([p.x, p.y, r]) geodesic_sphere(r, $fn=$fn/2);
        rotate([0, 0, twist]) translate([p.x, p.y, h-r]) geodesic_sphere(r, $fn=$fn/2);
    }
}

module rounded_bar(p1, p2, r, h) {
    hull() for(height = [r, h-r]) {
        translate([p1.x, p1.y, height]) geodesic_sphere(r, $fn=$fn/2);
        translate([p2.x, p2.y, height]) geodesic_sphere(r, $fn=$fn/2);
    }
}

module magnet_cutout() {
    union() {
        cylinder(h=magnet_height, d=magnet_diameter);
        translate([0, 0, magnet_height]) cylinder(h=hole_depth, d=hole_diameter);
    }
}

// this feels dumb but was the only way I could think to use relative offsetting in openscad
function tablet_stand_profile() = let(
    p0 = [chamfer_depth, edge_depth], //bottom edge of table chamfer vertical
    p1 = [chamfer_depth, edge_depth - chamfer_depth * tan(tablet_angle)], //back of tablet, top
    p2 = [tablet_contact_hypotenuse * cos(tablet_angle), edge_depth - tablet_contact_hypotenuse * sin(tablet_angle)], //back of tablet, bottom
    p3 = p2 - tablet_depth * [sin(tablet_angle), cos(tablet_angle)], //bottom of tablet, front
    p4 = p3 + tablet_lip * [-cos(tablet_angle), sin(tablet_angle)], //top of lip, inner
    p5 = p4 - strut_thickness * [sin(tablet_angle), cos(tablet_angle)], //top of lip, outer
    p6 = p5 + (tablet_lip + strut_thickness) * [cos(tablet_angle), -sin(tablet_angle)], //bottom of lip, outer
    p7 = p6 + (tablet_depth + strut_thickness * 2) * [sin(tablet_angle), cos(tablet_angle)], //underside angle
    p8 = [surface_to_slot+slot_height+wall_height_inner, 0], //lowest point on table
    p9 = [surface_to_slot+slot_height, 0], //bottom of magnet insert, outer
    p10 = [surface_to_slot+slot_height, slot_depth], //bottom of magnet insert, inner
    p11 = [surface_to_slot, slot_depth], //top of magnet insert
    p12 = [surface_to_slot, slot_depth-slot_depth_outer] //bottom of table chamfer, horizontal
) [p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12];

// probably could be in the profile definition, but this is simpler to process
tablet_stand_convexities = [
    true,
    true,
    false,
    false,
    true,
    true,
    true,
    true,
    true,
    false,
    true,
    true,
    false
];

tsp = tablet_stand_profile();
rounded_points = get_curve_centers(tsp, rounding_radius, tablet_stand_convexities);
strut_points = get_curve_centers(tsp, strut_thickness, tablet_stand_convexities);
bracer_back_points = critical_points(strut_points[9], strut_points[8], strut_thickness);
tablet_back_points = critical_points(strut_points[1], strut_points[7], strut_thickness);
lower_bracer_strut_points = get_strut_points(
    strut_points[7],
    strut_points[8],
    strut_points[9],
    strut_thickness * 2 //rethink this value
);
lower_bracer_anchor_points = get_strut_points(
    rounded_points[7],
    tablet_back_points[3],
    bracer_back_points[3],
    strut_thickness * 2
);
upper_bracer_strut_points = get_strut_points(
    strut_points[8],
    strut_points[9],
    strut_points[12],
    strut_thickness * 2
);
upper_bracer_anchor_points = get_strut_points(
    strut_points[1],
    tablet_back_points[2],
    bracer_back_points[2],
    strut_thickness * 2
);
text_center = let(mp=midpoint(rounded_points[7], tablet_back_points[2])) [mp.x, mp.y, slot_height/2];

//hulls defined by actual points on a polygon instead of indices to [rounded_points]
complex_hulls = [
    [   //tablet back
        rounded_points[2],
        rounded_points[1],
        rounded_points[0],
        strut_points[1],
        rounded_points[7]
    ],
    [   //lower lip
        rounded_points[2],
        rounded_points[3],
        rounded_points[6],
        rounded_points[7]
    ],
    [   //front lip
        rounded_points[3],
        rounded_points[4],
        rounded_points[5],
        rounded_points[6],
    ],
    [   //lower strut
        rounded_points[7],
        rounded_points[8],
        strut_points[8],
        strut_points[7]
    ],
    [   //back strut
        rounded_points[8],
        rounded_points[9],
        strut_points[9],
        strut_points[8]
    ],
    [   //magnet block
        rounded_points[9],
        rounded_points[10],
        rounded_points[11],
        rounded_points[12],
        rounded_points[12]
    ],
    [   //top strut
        rounded_points[12],
        rounded_points[0],
        critical_points(strut_points[0], strut_points[12], strut_thickness)[0],
        strut_points[12]
    ],
    [   //more top strut
        rounded_points[12],
        strut_points[12],
        strut_points[11]
    ],
    [   //horizontal bracer
        tablet_back_points[2],
        tablet_back_points[3],
        bracer_back_points[3],
        bracer_back_points[2]
    ],
    [   //lower bracer
        //tablet_back_points[2],
        //tablet_back_points[3],
        lower_bracer_anchor_points[0],
        tablet_back_points[3],
        lower_bracer_anchor_points[1],
        lower_bracer_strut_points[0],
        strut_points[8],
        lower_bracer_strut_points[1]
    ],
    [   //upper bracer
        upper_bracer_anchor_points[0],
        tablet_back_points[2],
        upper_bracer_anchor_points[1],
        upper_bracer_strut_points[0],
        strut_points[9],
        upper_bracer_strut_points[1]
    ]
];

if($preview) {
    //draw hard profile
    #for(p=tsp) color("red") translate([p.x, p.y, slot_height-0.25]) cylinder(h=1, r = rounding_radius);
    //draw points from rounded profile
    for(i=[0:len(rounded_points) - 1]) color("blue") let(p=rounded_points[i]) translate([p.x, p.y, slot_height-0.5]) union() {
        cylinder(h=1, r = rounding_radius);
        translate([1, -2]) linear_extrude(1) text(str(i), size=rounding_radius);
    }
    //draw points from strut profile
    for(i=[0:len(strut_points) - 1]) color("cyan") let(p=strut_points[i]) translate([p.x, p.y, slot_height-0.75]) union() {
        cylinder(h=1, r = rounding_radius);
        translate([1, -2]) linear_extrude(1) text(str(i), size=rounding_radius);
    }
}

difference() {
    union() { for(ch=complex_hulls)
        hull() for(i = [0:len(ch)-1]) let(
            p0 = ch[(i - 1 + len(ch)) % len(ch)],
            p1 = ch[i]
        ) rounded_bar(p0, p1, rounding_radius, slot_height);
    }
    //magnet cutout
    color("white") translate([tsp[11].x + slot_height/2, tsp[11].y, slot_height/2]) rotate([90, 0, 0]) magnet_cutout();
    //signature
    translate(text_center+[0,0,3*text_size/4]) rotate(text_rotation) translate(text_fudge)  mirror([0, 0, 1]) linear_extrude(text_depth) text("RedKrieg", size=text_size, font=text_font, halign = "center", valign = "center");
    translate(text_center-[0,0,3*text_size/4]) rotate(text_rotation) translate(text_fudge)  mirror([0, 0, 1]) linear_extrude(text_depth) text("2023", size=text_size, font=text_font, halign = "center", valign = "center");
}