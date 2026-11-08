shader_type spatial;

instance uniform vec3 emmision_color = vec3(1.0, 1.0, 1.0);
instance uniform float emmision_strength = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	EMISSION = emmision_color * emmision_strength;
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
