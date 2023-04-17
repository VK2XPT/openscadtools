//	Helpful modules

module helpers_info(verbose=false) {
//	if(verbose==false) {
		echo("module: fillet (r=1) { children }");
		echo("module: filletsection (r=1,size=[10,10], translation=[-5,-5]) { children }");
		echo("module: flip_copy (v=[0,0,1], previewonly=true) { children }");
		echo("module: grid (xy=[50,50], offset=[-25,-25], defaultline=0.005, step=0.5, linemods=[[5,0.2],[1,0.05]], colour=[0.75,0.2,0.2,0.5]);");
		echo("module: mirror_copy (v = [1, 0, 0]) { children }");
		echo("module: rotate_about (a, v, p=[0,0,0]) { children }");
		echo("module: diff () { children }");

		echo("function: quicksort (array)");
		echo("function: polar (array)");
		echo("function: triangle (polar=[[45,10],[90+45,10]])");
}


if(!is_undef(verbose)) {
	if (verbose==true) {
		echo("mytools/helpers.scad -- For more information use helpers_info()");
	}
}

module hull_line (array, $fn=90, r=1) {
	for(p=[0:len(array)-2]) {
		hull() {
			translate([array[p].x,array[p].y,0]) circle(r= array[p][2]==undef ? r : array[p][2]);
			translate([array[p+1].x,array[p+1].y,0]) circle(r= array[p+1][2]==undef ? r : array[p+1][2]);
		}
	}
}

function triangle (polar=[[45,10],[45+90,10]]) =
	concat([[0,0]],polar(polar)) ;

function polar (array) =
	[ for(i=[0:len(array)-1]) 
		[(array[search(quicksort(array)[i][0], array)[0]][1]) * cos(quicksort(array)[i][0]) ,
		(array[search(quicksort(array)[i][0], array)[0]][1]) * sin(quicksort(array)[i][0])
		]];

module grid (xy=[50,50], offset=[undef,undef], defaultline=0.005, step=0.5, linemods=[[5,0.2],[1,0.05]], colour=[0.75,0.2,0.2,0.5]) {
	if($preview) {
		xyoffset = offset[0]==undef ? xy*-0.5 : offset;
		translate(xyoffset) {
			color(colour) {
				linear_extrude(0.1) {
					
					for(x=[0:step:xy.x]) {
						line = 
							((x%linemods[0][0])==0) ? linemods[0][1] : ((x%linemods[1][0])==0) ? linemods[1][1] : defaultline;
						translate([x,xy.y/2,0]) {
							square([line,xy.y], center=true);
						}
					} /**/
					for(y=[0:step:xy.y]) {
						line = ((y%linemods[0][0])==0) ? linemods[0][1] : ((y%linemods[1][0])==0) ? linemods[1][1] : defaultline;
						translate([xy.x/2,y,0]) {
							square([xy.x,line], center=true);
						}
					}
				}
			}
		}
	}
}

module mirror_copy (v = [1, 0, 0]) {
	children();
	mirror(v) {
		children();
	}
}

module fillet (r=1) {
	offset(r = -r) {
		offset(delta = r) {
			children();
		}
	}
}

module filletsection (r=1,size=[10,10], translation=[-5,-5]) {
	difference() {
		children();
		translate(translation) {
			square(size);
		}
	}
	offset(r = -r) {
		offset(delta = r) {
			intersection() {
				children();
				translate(translation) {
					square(size);
				}
			}
		}
	}
	translate(translation) {
		square(size);
	}
}


module flip_copy (v=[0,0,1], previewonly=true) {
	children();
	rotate(v*180) {
		if(previewonly==false) {
			children();
		} else {
			if($preview==true) {
				color(alpha=0.5) {
					children();
				}
			}
		}
	}
}

module rotate_about (a, p=[0,0,0]) {
	translate(p) {
		if($preview) {
			#circle(d=1);
		}
		rotate(a) {
			translate(-p) {
				children();
			}
		}
	}
}

function quicksort(arr) = !(len(arr)>0) ? [] : let(
	pivot = arr[floor(len(arr)/2)],
	lesser= [ for (y = arr) if (y< pivot) y ],
	equal = [ for (y = arr) if (y == pivot) y ],
	greater = [ for (y = arr) if (y> pivot) y ]
) concat(
	quicksort(lesser), equal, quicksort(greater)
);

function range (q=[0:10]) =
	[ for(i=q) i];

module diff(offset=0.001) {
	if(!$preview) {
	// Render mode - pass through to difference
		difference() {
			children();
		}
	} else {
	// Preview mode - embiggen cutaways
		difference() {
			children(0);
			union() {
				for(i=[1:1:$children-1]) {
					translate([-offset*i,-offset*i,-offset*i]) {
						children(i);
					}
					translate([offset*i,offset*i,offset*i]) {
						children(i);
					}
				}
			}
		}
	}
}
