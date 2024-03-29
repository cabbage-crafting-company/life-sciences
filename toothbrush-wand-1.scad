// rendering fineness
$fa = 1;
$fs = 0.2;

// model parameters
attachmentRadius=5;
attachmentStemLength=8;
ballDiameter=35;
castingHoleDiameter=5;
epsilon=1/1024;
moldKeyDiameter=2.5;
moldWall=1;

// view
viewAttachment=false;
viewAttachmentCrossSection=false;
viewMold=false;
viewMoldCrossSection=true;
viewMoldSide=true;
viewMoldTop=true;
viewStem=true;

// guts
large=4*(ballDiameter+moldWall);
moldLip=(attachmentRadius+castingHoleDiameter/2+moldWall)/sqrt(2)
        +castingHoleDiameter/2+moldWall+epsilon;
stemDistance=cos(asin(2*attachmentRadius/ballDiameter))*ballDiameter/2;

if (viewAttachment) {
    translate([0, 0, 3*attachmentRadius+attachmentStemLength]) {
        rotate([180, 0, 0]) {
            oralBAttachment(true);
        }
    }
}
else if (viewAttachmentCrossSection) {
    intersection() {
        translate([-large/2, 0, -large/2]) {
            cube([large, large/2, large]);
        }
        oralBAttachment(true);
    }
}
else if (viewMold) {
    mold();
}
else if (viewMoldCrossSection) {
    intersection() {
        translate([-large/2, 0, -large/2]) {
            cube([large, large/2, large]);
        }
        mold();
    }
}
else if (viewMoldSide) {
    moldSide();
}
else if (viewMoldTop) {
    moldTop();
}
else if (viewStem) {
    oralBSteam();
}

module mold() {
    difference() {
        union() {
            translate([0, 0, ballDiameter/2+moldWall]) {
                sphere(r=ballDiameter/2+moldWall);
            }
            translate([
                    -ballDiameter/2-moldWall,
                    -moldWall,
                    0]) {
                cube([
                        ballDiameter+2*moldWall,
                        2*moldWall,
                        ballDiameter/2+2*moldWall+stemDistance]);
            }
            for (aa=[45:45:135]) {
                rotate([0, 0, aa]) {
                    translate([
                            -ballDiameter/2-moldWall,
                            -moldWall/2,
                            0]) {
                        cube([
                                ballDiameter+2*moldWall,
                                moldWall,
                                ballDiameter/2+moldWall]);
                    }
                }
            }
            hull() {
                for (aa=[45:90:315]) {
                    rotate([0, 0, aa]) {
                        translate([
                                attachmentRadius+castingHoleDiameter/2+moldWall,
                                0,
                                ballDiameter/2+moldWall]) {
                            cylinder(
                                    h=moldWall+stemDistance,
                                    r=castingHoleDiameter/2+moldWall);
                        }
                    }
                }
            }
            translate([
                    -ballDiameter/2-moldWall,
                    -moldLip,
                    ballDiameter/2+stemDistance]) {
                cube([
                        ballDiameter+2*moldWall,
                        2*moldLip,
                        2*moldWall]);
            }
        }
        translate([
                -ballDiameter/2-moldWall,
                -ballDiameter/2-moldWall,
                ballDiameter/2+2*moldWall+stemDistance]) {
            cube([
                    ballDiameter+2*moldWall,
                    ballDiameter+2*moldWall,
                    ballDiameter+2*moldWall]);
        }
        difference() {
            translate([0, 0, ballDiameter/2+moldWall]) {
                sphere(r=ballDiameter/2);
            }
            translate([
                    -ballDiameter/2,
                    -ballDiameter/2,
                    ballDiameter/2+moldWall+stemDistance]) {
                cube([
                        ballDiameter,
                        ballDiameter,
                        ballDiameter]);
            }
            translate([
                    0,
                    0,
                    ballDiameter/2+moldWall+stemDistance+epsilon]) {
                rotate([180, 0, 0]) {
                    oralBAttachment(false);
                }
            }
        }
        for (dx=[-1, 1]) {
            for (dy=[0, 1]) {
                translate([
                        dx*(ballDiameter/2
                                +moldWall
                                -moldKeyDiameter),
                        -2*moldWall,
                        dy*(ballDiameter/2
                                -moldKeyDiameter
                                +stemDistance)
                            +(1-dy)*moldKeyDiameter]) {
                    rotate([270, 0, 0]) {
                        cylinder(
                                h=4*moldWall,
                                r=moldKeyDiameter/2);
                    }
                }
            }
            for (dy=[-1, 1]) {
                translate([
                        dx*(ballDiameter/2+moldWall-moldKeyDiameter),
                        dy*moldLip/2,
                        ballDiameter/2-moldWall+stemDistance]) {
                    cylinder(h=4*moldWall, r=moldKeyDiameter/2);
                }
            }
        }
        for (aa=[45:90:315]) {
            rotate([0, 0, aa]) {
                translate([
                        attachmentRadius+castingHoleDiameter/2+moldWall,
                        0,
                        ballDiameter/2+moldWall+stemDistance/2]) {
                    cylinder(
                            h=stemDistance,
                            r=castingHoleDiameter/2);
                }
            }
        }
    }
}

module moldSide() {
    difference() {
        mold();
        translate([0, 0, ballDiameter/2+moldWall]) {
            sphere(r=ballDiameter/2-1);
        }
        translate([
                0,
                0,
                -attachmentStemLength
                    +ballDiameter/2
                    +stemDistance]) {
            cylinder(
                    h=2*attachmentStemLength,
                    r=attachmentRadius+epsilon);
        }
        translate([-large/2, -large, -large/2]) {
            cube([large, large, large]);
        }
        translate([
                -large/2,
                -large/2,
                ballDiameter/2+moldWall+stemDistance]) {
            cube([large, large, large]);
        }
    }
}

module moldTop() {
    translate([
            0,
            0,
            ballDiameter/2+2*moldWall+stemDistance]) {
        rotate([180, 0, 0]) {
            difference() {
                mold();
                difference() {
                    translate([
                            -large/2,
                            -large/2,
                            ballDiameter/2-large
                                +moldWall+stemDistance]) {
                        cube([large, large, large]);
                    }
                    translate([0, 0, ballDiameter/2+moldWall]) {
                        sphere(r=ballDiameter/2-1);
                    }
                    translate([
                            0,
                            0,
                            -attachmentStemLength
                                +ballDiameter/2
                                +stemDistance]) {
                        cylinder(
                                h=2*attachmentStemLength,
                                r=attachmentRadius+epsilon);
                    }
                }
            }
        }
    }
}

module oralBAttachment(stem) {
    difference() {
        union() {
            cylinder(
                    h=2*attachmentRadius+attachmentStemLength,
                    r=attachmentRadius);
            translate([
                    0,
                    0,
                    2*attachmentRadius+attachmentStemLength]) {
                sphere(r=attachmentRadius);
            }
            for (aa=[0, 90]) {
                rotate([0, 0, aa]) {
                    hull() {
                        for (dx=[-1, 1]) {
                            translate([
                                    dx*(attachmentRadius+attachmentRadius*(1-1/sqrt(2))),
                                    0,
                                    attachmentRadius+attachmentStemLength]) {
                                sphere(r=attachmentRadius/sqrt(2));
                            }
                        }
                    }
                }
            }
        }
        if (stem) {
            oralBSteam();
        }
    }
}


module oralBSteam() {
    stemLength=19.7;
    stemRadius=1.7;
    difference() {
        translate([0, 0, -1]) {
            cylinder(r=stemRadius, h=stemLength+1);
        }
        translate([-3, 0.3, stemLength-12.7]) {
            cube([6, 5, stemLength]);
        }
        translate([-2, -stemRadius, stemLength-5.9]) {
            rotate([0, 90, 0]) {
                cylinder(r=0.2, h=4);
            }
        }
    }
}
