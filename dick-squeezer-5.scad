// rendering fineness
$fa = 1;
$fs = 0.5;

// model parameters
beadCircles=4;
beadHeight=1;
castingHoleDiameter=10;
epsilon=1/128;
keyHoleDiameter=2.5;
keyHolesRadial=8;
keyHolesZ=8;
keyInnerDepth=5;
keyInnerError=0.5;
keyInnerLength=10;
length=170;
lobeGap=0.6;
lobes=5;
moldLip=10;
moldWall=1;
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
        dickSqueezer5();
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

module dickSqueezer5() {
    lobeColor=[0.25, 0.5, 1];
    function lobeZSmall(hh)=let (
            aa=90/lobes,
            rr=outerDiameter/2,
            zz=sqrt(square(lobeGap)/(4+square(PI*rr*aa/(90*hh)))),
            bb=aa*zz/hh)
        square(rr)
            >square(rr*sin(bb)-lobeCenterOffset*sin(aa))
            +square(rr*cos(bb)-lobeCenterOffset*cos(aa))
            +square(zz-hh);
    function square(xx)=xx*xx;
    assert(lobeZSmall(outerDiameter/4));
    assert(!lobeZSmall(outerDiameter/2));
    function binarySeachLobeZDistance(aa, bb, ll)
            =(0>=ll)
            ?assert("no more levels")
            :((aa+epsilon>=bb)
                    ?bb
                    :(let (cc=(aa+bb)/2)
                        lobeZSmall(cc/2)
                            ?binarySeachLobeZDistance(cc, bb, ll-1)
                            :binarySeachLobeZDistance(aa, cc, ll-1)));
    lobeZDistance=binarySeachLobeZDistance(outerDiameter/2, outerDiameter, 32);
    lobeRows=max(1, ceil(length/lobeZDistance)+1);
    color([1, 0.5, 0.25]) {
        difference() {
            cylinder(h=length, r=outerDiameter/2+wall);
            translate([0, 0, -epsilon]) {
                cylinder(h=length+2*epsilon, r=outerDiameter/2);
            }
        }
    }
    for (lai=[0:1:lobes-1]) {
        for (lzi=[0:1:lobeRows-1]) {
            intersection() {
                translate([0, 0, epsilon]) {
                    color(lobeColor) {
                        cylinder(h=length-2*epsilon, r=outerDiameter/2+wall/2);
                    }
                }
                rotate([0, 0, 360*lai/lobes+180*lzi/lobes]) {
                    translate([lobeCenterOffset, 0, length-lzi*lobeZDistance]) {
                        color(lobeColor) {
                            sphere(r=outerDiameter/2);
                        }
                        beadAngle=2*acos(
                                (outerDiameter*outerDiameter
                                        -beadHeight*outerDiameter
                                        -4*beadHeight*beadHeight)
                                    /((outerDiameter-beadHeight)*outerDiameter))
                                +360*lobeGap/(PI*outerDiameter);
                        translate([beadHeight/2-outerDiameter/2, 0, 0]) {
                            color([1, 0.25, 0.5]) {
                                sphere(r=3*beadHeight/2);
                            }
                        }
                        for (bci=[1:1:beadCircles]) {
                            beads=floor(2*PI*bci);
                            for (bi=[0:1:beads-1]) {
                                rotate([10*bci+360*bi/beads, 0, 0]) {
                                    rotate([0, 0, bci*beadAngle]) {
                                        translate([beadHeight/2-outerDiameter/2, 0, 0]) {
                                            color([1, 0.25, 0.5]) {
                                                sphere(r=3*beadHeight/2);
                                            }
                                        }
                                    }
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
            dickSqueezer5();
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
        cube([keyInnerLength, keyInnerLength, keyInnerDepth+moldWall/2]);
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
                    zi*(length+moldWall-keyInnerError-keyInnerDepth)]) {
                cube([
                        keyInnerError+keyInnerLength,
                        keyInnerError+keyInnerLength,
                        keyInnerError+keyInnerDepth+moldWall]);
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
