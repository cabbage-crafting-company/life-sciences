// rendering fineness
$fa = 1;
$fs = 0.5;

// model parameters
bumpColumns=4;
bumpDiameter=8;
bumpDistanceRadial=14;
bumpDistanceZ=8;
bumpHeight=1;
castingHoleDiameter=10;
epsilon=1/128;
keyHoleDiameter=2.5;
keyHolesRadial=8;
keyHolesZ=8;
keyInnerError=0.5;
keyInnerHeight=5;
keyInnerLength=10;
length=160;
lobeGap=0.6;
lobes=5;
moldLip=10;moldWall=1;
outerDiameter=55;
wall=4;

// view
viewMoldBottom=false;
viewMoldCrossSection=false;
viewMoldInner=false;
viewMoldOuter=false;
viewMoldTop=false;
viewSqueezerCrossSection=true;

// guts
if (viewMoldBottom) {
    moldBottomTop(true);
}
else if (viewMoldCrossSection) {
    crossSection() {
        mold();
    }
}
else if (viewMoldInner) {
    moldInner();
}
else if (viewMoldOuter) {
    moldOuter();
}
else if (viewMoldTop) {
    moldBottomTop(false);
}
else if (viewSqueezerCrossSection) {
    crossSection() {
        dickSqueezer4();
    }
}

lobeCenterOffset=outerDiameter*cos(180/lobes-180*lobeGap/(outerDiameter*PI));
echo(" ### inner diameter", 2*lobeCenterOffset-outerDiameter);

moldDiameter=2*moldLip+2*moldWall+outerDiameter+2*wall+1;

module crossSection() {
    difference() {
        children();
        translate([-moldDiameter/2, -moldDiameter/2, length/2]) {
            cube([moldDiameter, moldDiameter/2, length+2*moldWall]);
        }
    }
}

module dickSqueezer4() {
    color([1, 0.5, 0.25]) {
        difference() {
            cylinder(h=length, r=outerDiameter/2+wall);
            translate([0, 0, -epsilon]) {
                cylinder(h=length+2*epsilon, r=outerDiameter/2);
            }
        }
    }
    color([0.25, 0.5, 1]) {
        intersection() {
            translate([0, 0, epsilon]) {
                cylinder(h=length-2*epsilon, r=outerDiameter/2+wall/2);
            }
            for (li=[0:1:lobes-1]) {
                rotate([0, 0, 360*li/lobes]) {
                    translate([lobeCenterOffset, 0, epsilon]) {
                        cylinder(h=length-2*epsilon, r=outerDiameter/2);
                    }
                }
            }
        }
    }
    color([1, 0.25, 0.5]) {
        bumpRows=floor((length-bumpDiameter)/bumpDistanceZ);
        for (bi=[0:1:bumpColumns-1]) {
            for (li=[0:1:lobes-1]) {
                for (zi=[0:1:bumpRows-1]) {
                    rotate([0, 0, 360*li/lobes]) {
                        translate([lobeCenterOffset, 0, 0]) {
                            rotate([
                                    0,
                                    0,
                                    bi*bumpDistanceRadial
                                        -(bumpColumns-1)*bumpDistanceRadial/2]) {
                                translate([
                                        bumpDiameter/2-bumpHeight-outerDiameter/2,
                                        0,
                                        zi*bumpDistanceZ
                                            +(length-(bumpRows-1)*bumpDistanceZ)/2]) {
                                    sphere(r=bumpDiameter/2);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

module mold() {
    difference() {
        union() {
            cylinder(
                    h=length+2*moldWall,
                    r=moldWall+outerDiameter/2+wall);
            translate([
                    -moldLip-moldWall-outerDiameter/2-wall,
                    -moldWall,
                    0]) {
                cube([2*moldLip+2*moldWall+outerDiameter+2*wall,
                        2*moldWall,
                        length+2*moldWall]);
            }
            for (zi=[0, 1]) {
                translate([0, 0, zi*length]) {
                    cylinder(
                            h=2*moldWall,
                            r=moldLip+moldWall+outerDiameter/2+wall);
                }
            }
        }
        translate([0, 0, moldWall]) {
            dickSqueezer4();
        }
        keyHoleDistanceZ=(length-keyHoleDiameter-2*moldWall)/keyHolesZ;
        for (dx=[-1, 1]) {
            for (zi=[0:1:keyHolesZ-1]) {
                translate([
                        dx*(moldLip/2+moldWall+outerDiameter/2+wall),
                        2*moldWall,
                        zi*keyHoleDistanceZ
                            +(length+2*moldWall-(keyHolesZ-1)*keyHoleDistanceZ)/2]) {
                    rotate([90, 0, 0]) {
                        cylinder(h=4*moldWall, r=keyHoleDiameter/2);
                    }
                }
            }
        }
        outerHalfCircumference=outerDiameter*PI/2;
        keyHoleDistanceRadial=180*(outerHalfCircumference-keyHoleDiameter-2*moldWall)
                /(keyHolesRadial*outerHalfCircumference);
        for (ri=[0:1:keyHolesRadial-1]) {
            for (yi=[0, 1]) {
                for (zi=[0, 1]) {
                    rotate([
                            0,
                            0,
                            yi*180
                                +ri*keyHoleDistanceRadial
                                +(180-(keyHolesRadial-1)*keyHoleDistanceRadial)/2]) {
                        translate([
                                moldLip/2+moldWall+outerDiameter/2+wall,
                                0,
                                zi*length-moldWall]) {
                            cylinder(
                                    h=4*moldWall,
                                    r=keyHoleDiameter/2);
                        }
                    }
                }
            }
        }
        for (li=[0:1:lobes-1]) {
            rotate([0, 0, 360*li/lobes]) {
                translate([
                        lobeCenterOffset/2+wall/2,
                        0,
                        length]) {
                    cylinder(h=3*moldWall, r=castingHoleDiameter/2);
                }
            }
        }
    }
}

module moldBottomTop(bottom) {
    intersection() {
        if (bottom) {
            mold();
        }
        else {
            translate([0, 0, length+2*moldWall]) {
                rotate([180, 0, 0, ]) {
                    mold();
                }
            }
        }
        translate([-moldDiameter/2, -moldDiameter/2, epsilon]) {
            cube([moldDiameter, moldDiameter, moldWall+2*epsilon]);
        }
    }
    translate([-keyInnerLength/2, -keyInnerLength/2, moldWall/2]) {
        cube([keyInnerLength, keyInnerLength, keyInnerHeight+moldWall/2]);
    }
}

module moldInner() {
    difference() {
        intersection() {
            mold();
            translate([0, 0, moldWall+2*epsilon]) {
                cylinder(h=length-4*epsilon, r=outerDiameter/2+wall/2);
            }
        }
        for (zi=[0, 1]) {
            translate([
                    -keyInnerError/2-keyInnerLength/2,
                    -keyInnerError/2-keyInnerLength/2,
                    zi*(length+moldWall-keyInnerError-keyInnerHeight)]) {
                cube([
                        keyInnerError+keyInnerLength,
                        keyInnerError+keyInnerLength,
                        keyInnerError+keyInnerHeight+moldWall]);
            }
        }
    }
}

module moldOuter() {
    intersection() {
        difference() {
            mold();
            cylinder(h=length+2*moldWall, r=outerDiameter/2+wall/2);
        }
        translate([-moldDiameter/2, 0, moldWall+2*epsilon]) {
            cube([moldDiameter, moldDiameter/2, length-4*epsilon]);
        }
    }
}
