token_thickness = 2;
base_thickness = 1.8;
font_face = "Impact:style=Regular";
font_size = 5.2;

token_width = 18;
token_height = 10;

border_thickness = 0.8;

token_text = "+1/+1";

$fn=101;

module pill(w, h) {
    intersection() {
        square([w*2, h], center=true);
        radius = sqrt(w*w/4+h*h/4);
        circle(radius);
    }
}

module base() {
    linear_extrude(height=token_thickness) pill(token_width, token_height);
}

module border_cutout() {
    translate([0, 0, base_thickness]) linear_extrude(height=token_thickness-base_thickness) pill(token_width-border_thickness*2, token_height-border_thickness*2);
}

module token_text(t) {
    linear_extrude(height=token_thickness) text(t, size=font_size, font=font_face, halign="center", valign="center");
}

module token(t) {
    union() {
        difference() {
            base();
            border_cutout();
        }
        token_text(t);
    }
}

token(token_text);