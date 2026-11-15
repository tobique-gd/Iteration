shader_type canvas_item;

instance uniform float progress : hint_range(0.0, 1.0) = 1.0;

uniform vec4 ring_color : source_color = vec4(0.996, 0.996, 0.980, 1.0);
uniform float outer_size : hint_range(0.05, 0.5) = 0.35;
uniform float thickness : hint_range(0.01, 0.4) = 0.11;
uniform bool clockwise = true;

float sdfSquare(vec2 pos, float size) {
	vec2 d = abs(pos) - vec2(size);
	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float perimeter_pos(vec2 p, float size) {
	float side_len = 2.0 * size;
	float side;
	float t;

	if (abs(p.y) >= abs(p.x)) {
		if (p.y > 0.0) {
			side = 0.0;
			t = (size - p.x) / side_len;
		} else {
			side = 2.0;
			t = (p.x + size) / side_len;
		}
	} else {
		if (p.x < 0.0) {
			side = 1.0;
			t = (size - p.y) / side_len;
		} else {
			side = 3.0;
			t = (p.y + size) / side_len;
		}
	}

	return (side + clamp(t, 0.0, 1.0)) * 0.25;
}

void fragment() {
	vec2 center_uv = UV - vec2(0.5);

	float inner_size = max(0.0, outer_size - thickness);
	float dist_outer = sdfSquare(center_uv, outer_size);
	float dist_inner = sdfSquare(center_uv, inner_size);

	float square_ring_mask = step(dist_outer, 0.0) * step(0.0, dist_inner);

	float pos = perimeter_pos(-center_uv, outer_size);
	if (!clockwise) {
		pos = 1.0 - pos;
	}

	float radial_mask = step(pos, progress);
	if (progress <= 0.0) {
		radial_mask = 0.0;
	}

	float final_alpha = square_ring_mask * radial_mask * ring_color.a * COLOR.a;
	
	
	COLOR = vec4(ring_color.rgb, final_alpha);
}