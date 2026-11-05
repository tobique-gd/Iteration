shader_type canvas_item;

instance uniform float progress = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

vec2 rotateUV45(vec2 uv) {
    uv -= 0.5;
    const float f = 0.70710678118;
    uv = vec2(uv.x * f - uv.y * f, uv.x * f + uv.y * f);
    uv += 0.5;
    return uv;
}


void fragment() {
	float y = rotateUV45(UV).y;
	
	float remapped_y = 1.0 - ((y + 0.25) / 1.5);
	float mask = step(remapped_y, progress);
	vec3 color = vec3(0.996078431372549, 0.996078431372549, 0.9803921568627451);
	COLOR = vec4(color, mask * COLOR.a);
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
