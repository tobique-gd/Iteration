shader_type canvas_item;

instance uniform float progress = 1.0;

void vertex() {
}

vec2 rotateUV45(vec2 uv) {
	uv -= 0.5;
	const float f = 0.70710678118;
	uv = vec2(uv.x * f - uv.y * f, uv.x * f + uv.y * f);
	uv += 0.5;
	return uv;
}

float sdfSquare(vec2 pos, float size) {
	vec2 d = abs(pos) - vec2(size);
	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

void fragment() {
	float y = rotateUV45(UV).y;
	float remapped_y = 1.0 - ((y + 0.25) / 1.5);
	float mask = step(remapped_y, progress);
	
	vec2 center_uv = UV - vec2(0.5);
	
	float outer_size = 0.38;
	float dist_outer = sdfSquare(center_uv, outer_size);
	float outer_hole_mask = step(0.0, dist_outer);
	
	float ring_outer_size = 0.24;
	float ring_inner_size = 0.13;
	
	float dist_ring_outer = sdfSquare(center_uv, ring_outer_size);
	float dist_ring_inner = sdfSquare(center_uv, ring_inner_size);
	
	float square_ring_mask = step(dist_ring_outer, 0.0) * step(0.0, dist_ring_inner);
	
	float progress_outer = clamp(progress * 2.0 - 1.0, 0.0, 1.0);
	float progress_ring = clamp(progress * 2.0, 0.0, 1.0);
	
	float mask_outer = step(remapped_y, progress_outer);
	float mask_ring = step(remapped_y, progress_ring);
	
	float final_outer = outer_hole_mask * mask_outer;
	float final_ring = square_ring_mask * mask_ring;
	
	float final_shape_mask = clamp(final_outer + final_ring, 0.0, 1.0);
	
	vec3 color = vec3(0.99607843137, 0.99607843137, 0.98039215686);
	float alpha = final_shape_mask * COLOR.a;
	
	COLOR = vec4(color, alpha);
}
