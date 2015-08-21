

board_l = 122.2;
board_w = 84;
board_h = 1.5;

strut_d = 7;
strut_h = 9.5;

add_extrude = 10;
mic_dia = 13;
powerplug_dia = 10;

wall = 2;
wtb = 0.5; // wall to board

ground_h = 1.9;
heading_h = 1.7;
housing_h = 30;

housing_lower_h_above_board = 6.2;
screw_head_h = 2.5 + 0.3; // +security
hold_depth = housing_lower_h_above_board - screw_head_h;
hold_w = 6;

housing_lower_h = ground_h + strut_h + board_h + housing_lower_h_above_board;


module board(aas=1) {
    translate([0, 0, -board_h])
    cube([board_l,board_w, board_h], center=false);
    for (i = [-1, 1]) {
        for (j = [-1, 1]) {
            translate([i*(board_l - strut_d)/2 + board_l/2,
                       j*(board_w - strut_d)/2 + board_w/2,
                        -strut_h-board_h])
                cylinder(h=strut_h, d=strut_d, center=false);
        }
    }
    
    module assi(aas) {
        minkowski() {
            cube([aas, aas, aas], center=true);
            union() {
                children([0:$children-1]);
            }
        }
    }
    
    module to_left_side(y=0) {
        translate([board_l,y,0])
            mirror([1,0,0])
                children([0:$children-1]);
    }
    
    module to_front_side(x=0) {
       translate([x, board_w, 0])
          rotate([0,0,-90])
              children([0:$children-1]);
    }

    module to_back_side(x=0) {
        // this mirrors the part, but this should be no problem
        translate([x,0,0])
        rotate([0,0,90])
        mirror([0,1,0])
        children([0:$children-1]);
    }

    // ######### PIN HEADERS
    
    module 12_pin(aas) {
        rotate([0,0,90]) {
            assi(aas) union() {
                cube([16, 2 + add_extrude, 5]);
                translate([-1,0,-1])
                    cube([18, add_extrude, 7]);
            }
        }
    }
    
    // JB JC JD JE
    for (J_x = [19, 42, 65, 88]) {
        to_front_side(J_x)
            12_pin(aas);
    }
    
    // JA
    translate([0, 59.5, 0])
      rotate([0,0,0])
        12_pin(aas);

    // JF
    to_left_side(40.5)
        12_pin(aas);

    // ######### MIC CONNECTORS
    
    module mic(aas) {
        translate([0,3,3])
            rotate([0,-90,0]) assi(aas) union() {
                cylinder(h=1+add_extrude,d=mic_dia);
                cylinder(h=2+add_extrude,d=5.5);
            }
    }
    
    for(mic_x = [29.5, 39.5, 49.5])
        translate([0,mic_x,0])
            mic(aas);

    // ##### VGA
    
    module vga(aas) {
        rotate([0,0,90]) {
            assi(aas)
                cube([31, 7, 13]);
        }
    }
    //vga(aas);
    to_back_side(13)
        vga(aas);

    // ####### HDMI
    
    module hdmi(aas) {
        assi(aas)
        rotate([0,0,90]) {
            cube([15, 2+add_extrude, 7]);
            translate([-3.5,0,-3])
            cube([22, add_extrude, 13]);
        }
    }

    to_back_side(64)
        hdmi(aas);

    // ######## ETH
    
    module ethernet(aas) {
        assi(aas)
        rotate([0,0,90])
            translate([-0,0 ,-2]) // +2 to bot for splint
                cube([16, 1+add_extrude, 14+2]);
    }
    
    to_back_side(83.5)
        ethernet(aas);


    // ####### Power
    module power(aas) {
        assi(aas)
            rotate([0,-90,0]) {
                cube([11, 9, 0.3]);
            }
        assi(aas)
        // aligned to black housing 
        translate([0,1,0])
        // aligned to side of hole
        translate([0,3.5,6.5])
            rotate([0,-90,0]) union() {
               cylinder(h=1+add_extrude,d=powerplug_dia);
                cylinder(h=2+add_extrude,d=7);
            }
    }
    
    to_back_side(100)
        power(aas);


    // ####### MICROUSB
    
    
    module microusb(aas) {
        assi(aas)
        rotate([0,0,90]) {
            cube([8, 1+add_extrude, 2]);
            translate([-1.5,0,-3])
                cube([11, add_extrude, 8+1]); // plug (+1 for lower upper sep)
        }

    }
    
    to_left_side(26.5)
        microusb(aas);
    
    translate([0, 0, -board_h-2])
    to_left_side(63)
        microusb(aas);
    
    
    // ####### USB
    
    
    module usb(aas) {
        assi(aas)
        rotate([0,0,90]) {
            cube([15, 1+add_extrude, 8]);
            translate([-1,0,-0.8])
                cube([17, add_extrude, 9]); // plug
        }

    }
    
    to_left_side(60)
        usb(aas);


    // ######## MicroSD
    module sd(aas) {
        assi(aas)
        rotate([0,0,90]) {
            cube([11, 1+add_extrude, 2.5]);
            translate([-3.5,0,-9])
                cube([18, add_extrude, 9+2+5]); // free room for fingers
        }

    }
    
    to_back_side(50)
        translate([0,0,-2])
        mirror([0,0,1])
        sd(aas);
    
    
    // ######## Wall Killer (for too little gaps between connectors)
    
    module gap_killer(w=10, h=10, into_ground=1.25) { 
        rotate([0,0,90]) {
            translate([0, -0.1, -into_ground])
            cube([w, 1+add_extrude, h+into_ground]);
        }
    }
    
    to_back_side(43) // between VGA and microUSB
        gap_killer(4, 7);
    
    to_back_side(79) // between HDMI and ETH
        gap_killer(5, 10.5);
    
    to_left_side(36) // between PROG and UART
        gap_killer(6, 6.25);

    to_left_side(56) // between USB and UART
        gap_killer(4, 6.25);

    //for(gap_x = [35, 57, 80])
    //    to_front_side(gap_x) // between Jx
    //        gap_killer(8, 6.25);

}

//translate([-200, -200, 0])
//    board();

module board_in_housing() {
    translate([0, 0, board_h + strut_h + ground_h])
        board();
}


module housing() {
    difference() {
        translate([-wall-wtb, -wall-wtb, 0])
            cube([2*wall + 2*wtb + board_l,
                  2*wall + 2*wtb + board_w,
                  housing_h]);
        
        translate([-wtb, -wtb, ground_h])
            cube([2*wtb + board_l,
                  2*wtb + board_w,
                  housing_h-ground_h-heading_h]);
    }
}

module housing_with_holes() {
    difference() {
        housing();
        board_in_housing();
    }
}


module bot_housing() {
    difference() {
        intersection() {
            translate([-10, -10, 0])
                cube([board_l + 20, board_w + 20, housing_lower_h]);
            housing_with_holes();
        }
        union() {
            for ( y_split=[23, 60] ) {
            for ( x_split=[21:9:105]) {
                translate([x_split, y_split, 0])
                    cube([4, 30, 10], center=true);
            }
            }
        }
    }
}


module zybo() {
    rotate([0, 0, 180])
    difference() {
        linear_extrude(height = 10) {
            text(text = str("ZYBO"), font = "Liberation Sans:style=Bold", size = 20);
        }
        translate([43,-10,0])
            cube([3, 50, 10]);
        translate([63.5,-10,0])
            cube([3, 50, 10]);
    }
 }

module x() {
    rotate([0, 0, 180])
    difference() {
        linear_extrude(height = 10) {
            text(text = "X", font = "Liberation Sans:style=Bold", size = 12, valign="center", halign="center");
        }
    }
 }

module xilinx() {
    rotate([0, 0, 180])
    difference() {
        linear_extrude(height = 10) {
            text(text = "XILINX", font = "Liberation Sans:style=Bold", size = 10, halign="center");
        }
    }
 }

module triangle() {
    linear_extrude(height=10)
    scale(14)
    rotate([0, 0, 180])
    translate([-0.5, -sin(30)/2, 0])
    polygon(points=[[0,0],[0.5,cos(30)*1],[1,0]], paths=[[0,1,2]]);
}

//triangle();


module hold(_hold_depth=hold_depth) {
   translate([0,0,-housing_h+housing_lower_h-_hold_depth])
        cube([hold_w, hold_w, housing_h-housing_lower_h+_hold_depth]);
}


module top_housing() {
    difference() {
        housing_with_holes();
        translate([-10, -10, -1])
            cube([board_l + 20, board_w + 20, housing_lower_h+1]);
        translate([100,28,housing_h-2])
            zybo();
        for(button_x = [18, 28, 38, 48])
            translate([button_x,64,housing_h-2])
            triangle();
        for(button_x = [27, 37, 85, 96])
            translate([button_x,42,housing_h-2])
            triangle();
        //for(button_x = [(79 + 86.5) / 2, (93 + 100) / 2]) //79, 86.5, 93, 100
        //    translate([button_x, 64.5, housing_h-2])
        //        x();
        translate([90, 67, housing_h-2])
            xilinx();
    }
    overlap = 0.00;
    translate([0, 0, housing_h]) {
        for(x=[-wtb -overlap, board_l - hold_w + overlap + wtb])
            for(y=[-wtb -overlap, board_w - hold_w + overlap + wtb])
                translate([x, y, 0])
                    hold();
    }
}


module create() {
    
%bot_housing();
top_housing();
board_in_housing();

translate([-200, 100, 0])
    bot_housing();

translate([10, -140, 0])
    housing_with_holes();

rotate([180, 0, 0]) translate([0, -200, -housing_h])
    top_housing();

translate([-150, -150, 0])
    board();

}

module print() {
    
    // #### for Printing
    rotate([180, 0, 0]) translate([0, 10, -housing_h]) top_housing();

    bot_housing();
}

create();
//print();
