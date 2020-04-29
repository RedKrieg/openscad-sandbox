slots = 10;

thickness = 3.6;
width = 20.1;
spacer = 1.5;
length = ((thickness + spacer) * slots) + spacer;
font = min(length/8, 10);

difference()
{
   cube([width+spacer*2,length,width/2+spacer*3]);
   
   for(i=[0:(slots-1)])
   { 
        translate([spacer,spacer+(i*(thickness + spacer)),spacer])
        cube([width,thickness,width/2+spacer*3]);
   }
   
   translate([width/2+spacer,0,width/2+spacer*3])
   rotate([-90,0,0])
   cylinder(length+spacer*2, width/2-spacer, width/2-spacer, $fn = 50);

   translate([width+spacer*1.75,5,3])
   rotate([90,0,90])
   linear_extrude(height = spacer/2) 
   {
        text("CR 2032",font);
   }
}

translate([spacer*0.75,0,width/2+spacer*2.5])
rotate([-90,0,0])
cylinder(length,0.5,0.5,$fn = 30);

