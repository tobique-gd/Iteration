shader_type canvas_item;

uniform int levels = 3;
uniform float spread = 0.01;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture,
	filter_linear,
	repeat_disable;

vec3 chromatic_slice(float t) {
	vec3 res = vec3(
		1.0 - t,
		1.0 - abs(t - 1.0),
		t - 1.0
	);
	return max(res, 0.0);
}

void fragment() {
	vec3 sum = vec3(0.0);
	COLOR.rgb = vec3(0.0);

	vec2 offset = (UV - vec2(0.5)) * vec2(1.0, -1.0);

	for (int i = 0; i < levels; i++) {
		float t = 2.0 * float(i) / float(levels - 1);

		vec3 slice = chromatic_slice(t);
		sum += slice;

		vec2 slice_offset = (t - 1.0) * spread * offset;

		vec2 sample_uv = clamp(
			SCREEN_UV + slice_offset,
			vec2(0.0),
			vec2(1.0)
		);

		COLOR.rgb += slice * texture(
			SCREEN_TEXTURE,
			sample_uv
		).rgb;
	}

	COLOR.rgb /= max(sum, vec3(0.0001));
}