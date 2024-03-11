// rendering fineness
$fa = 1;
$fs = 0.2;

// model parameters
baseDepth=8;
baseHeight=25;
baseHoleDiameter=10;
baseRoundingRadius=3;
baseWidth=60;
epsilon=1/1024;
moldKeyDiameter=2.5;
moldWall=1.5;
plugLength=56;
plugMajorDiameter=40;
plugMinorDiameter=35;
plugPointDiameter=5;
stemDiameter=15;
stemLength=20;

// view
viewMold=false;
viewPlug=true;

// guts
if (viewMold) {
    mold();
}
else if (viewPlug) {
    plug();
}

module mold() {
    plugHeight=max(baseHeight, plugMinorDiameter, plugPointDiameter);
    plugDiameter=max(plugMinorDiameter, plugPointDiameter);
    translate([0, 0, moldWall+plugHeight/2]) {
        rotate([270, 0, 0]) {
            difference() {
                union() {
                    translate([-plugDiameter/2-moldWall, 0, 0]) {
                        cube([
                                plugDiameter+2*moldWall,
                                plugHeight/2+moldWall,
                                baseDepth+moldWall+plugLength+stemLength]);
                    }
                    translate([-baseWidth/2-moldWall, 0, 0]) {
                        cube([
                                baseWidth+2*moldWall,
                                plugHeight/2+moldWall,
                                baseDepth+moldWall]);
                    }
                }
                translate([0, 0, -epsilon]) {
                    plug();
                }
                for (sx=[-1, 1]) {
                    scale([sx, 1, 1]) {
                        for (ki=[0, 1]) {
                            keyWallDistance=moldWall/2+plugDiameter/4-stemDiameter/4;
                            translate([
                                    moldWall+plugDiameter/2-keyWallDistance,
                                    moldWall+plugHeight/2+epsilon,
                                    (1-ki)*(baseDepth+stemLength/2)
                                        +ki*(baseDepth
                                            +moldWall
                                            +plugLength
                                            +stemLength
                                            -keyWallDistance)]) {
                                rotate([90, 0, 0]) {
                                    cylinder(
                                            h=moldWall+plugHeight/2+2*epsilon,
                                            r=moldKeyDiameter/2);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

module plug() {
    color([1, 0, 0.5]) {
        plugBase();
    }
    color([0.5, 1, 0]) {
        plugPlug();
    }
    color([0, 0.5, 1]) {
        plugStem();
    }
}

module plugBase() {
    difference() {
        union() {
            translate([-(baseWidth-baseHeight+2*epsilon)/2, 0, 0]) {
                rotate([90, 0, 90]) {
                    linear_extrude(height=baseWidth-baseHeight+2*epsilon) {
                        difference() {
                            translate([-baseHeight/2, 0]) {
                                square([baseHeight, baseDepth]);
                            }
                            for (sx=[-1, 1]) {
                                scale([sx, 1, 1]) {
                                    translate([
                                            baseHeight/2-baseRoundingRadius,
                                            baseDepth-baseRoundingRadius]) {
                                        difference() {
                                            square([
                                                    baseRoundingRadius+epsilon,
                                                    baseRoundingRadius+epsilon]);
                                            circle(r=baseRoundingRadius);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            for (sx=[-1, 1]) {
                scale([sx, 1, 1]) {
                    translate([(baseWidth-baseHeight)/2, 0, 0]) {
                        rotate([0, 0, 270]) {
                            rotate_extrude(angle=180)
                            {
                                difference() {
                                    square([baseHeight/2, baseDepth]);
                                    translate([
                                            baseHeight/2-baseRoundingRadius,
                                            baseDepth-baseRoundingRadius]) {
                                        difference() {
                                            square([
                                                    baseRoundingRadius+epsilon,
                                                    baseRoundingRadius+epsilon]);
                                            circle(r=baseRoundingRadius);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        for (sx=[-1, 1]) {
            scale([sx, 1, 1]) {
                translate([(baseWidth-baseHeight)/2, 0, -epsilon]) {
                    cylinder(h=baseDepth+2*epsilon, r=baseHoleDiameter/2);
                }
            }
        }
    }
}

module plugPlug() {
    translate([
            0,
            0,
            baseDepth+plugMajorDiameter/2+stemLength]) {
        rotate_extrude() {
            hull() {
                intersection() {
                    union() {
                        scale([plugMinorDiameter/plugMajorDiameter, 1]) {
                            circle(r=plugMajorDiameter/2);
                        }
                        translate([0, plugLength-(plugMajorDiameter+plugPointDiameter)/2]) {
                            circle(r=plugPointDiameter/2);
                        }
                    }
                    translate([0, -plugMajorDiameter/2-epsilon]) {
                        square([
                                max(plugMinorDiameter, plugPointDiameter)/2+epsilon,
                                plugLength+2*epsilon]);
                    }
                }
            }
        }
    }
}

module plugStem() {
    translate([0, 0, baseDepth/2]) {
        cylinder(
                h=baseDepth/2+plugMajorDiameter/2+stemLength,
                r=stemDiameter/2);
    }
}
