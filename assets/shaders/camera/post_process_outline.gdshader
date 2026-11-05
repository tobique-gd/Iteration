
shader_type spatial;
render_mode unshaded, depth_draw_opaque, depth_prepass_alpha;

// Base shader:
// https://godotshaders.com/shader/3d-pixel-art-outline-highlight-post-processing-shader/

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;

group_uniforms Outline_Settings;
uniform vec3 shadow_color : source_color = vec3(0.0);
uniform float outline_size : hint_range(1.0, 10.0, 0.5) = 2.0;
uniform float depth_threshold : hint_range(0.01, 2.0, 0.01) = 0.25;
uniform float normal_threshold : hint_range(0.01, 1.0, 0.01) = 0.4;

group_uniforms Luminance_Settings;
uniform float brightness_outline_size : hint_range(1.0, 10.0, 0.5) = 2.0;
uniform float brightness_sensitivity : hint_range(0.1, 5.0, 0.1) = 1.0;
uniform float brightness_threshold : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float brightness_strength : hint_range(0.0, 5.0, 0.1) = 1.0;


void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}


vec2 getDepth(vec2 screen_uv, sampler2D depth_texture, mat4 inv_projection_matrix) {
	float raw_depth = texture(depth_texture, screen_uv).r;
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, raw_depth);
	vec4 view_space = inv_projection_matrix * vec4(ndc, 1.0);
	view_space.xyz /= view_space.w;
	return vec2(-view_space.z, raw_depth);
}


float getLuminance(vec3 col) {
	return dot(col, vec3(0.299, 0.587, 0.114));
}


void fragment() {
	vec2 outline_pixel_size = (1.0 / VIEWPORT_SIZE.xy) * outline_size;
	vec2 brightness_pixel_size = (1.0 / VIEWPORT_SIZE.xy) * brightness_outline_size;

	vec2 center_depth_data = getDepth(SCREEN_UV, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
	float center_depth = center_depth_data.x;
	vec3 center_normal = texture(NORMAL_TEXTURE, SCREEN_UV).rgb * 2.0 - 1.0;
	vec3 center_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	float center_lum = getLuminance(center_color);

	vec2 offsets[4] = vec2[](
		vec2(-1.0,  0.0),
		vec2( 1.0,  0.0),
		vec2( 0.0, -1.0),
		vec2( 0.0,  1.0)
	);

	float depth_diff = 0.0;
	float normal_diff = 0.0;
	float lum_diff = 0.0;

	float min_depth = center_depth;
	vec2 min_depth_data = center_depth_data;
	vec3 shadow_sample_color = center_color;

	for (int i = 0; i < 4; i++) {
		vec2 outline_uv = SCREEN_UV + offsets[i] * outline_pixel_size;

		vec2 sample_depth_data = getDepth(outline_uv, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		float sample_depth = sample_depth_data.x;

		depth_diff += abs(center_depth - sample_depth);

		if (sample_depth < min_depth) {
			min_depth = sample_depth;
			min_depth_data = sample_depth_data;
			shadow_sample_color = texture(SCREEN_TEXTURE, outline_uv).rgb;
		}

		vec3 sample_normal = texture(NORMAL_TEXTURE, outline_uv).rgb * 2.0 - 1.0;
		normal_diff += 1.0 - clamp(dot(center_normal, sample_normal), 0.0, 1.0);


		vec2 brightness_uv = SCREEN_UV + offsets[i] * brightness_pixel_size;

		vec3 sample_color = texture(
			SCREEN_TEXTURE,
			brightness_uv + offsets[i] * brightness_pixel_size * (brightness_sensitivity - 1.0)
		).rgb;

		float sample_lum = getLuminance(sample_color);
		lum_diff += abs(center_lum - sample_lum);
		}

	depth_diff /= 4.0;
	normal_diff /= 4.0;
	lum_diff /= 4.0;

	depth_diff = smoothstep(depth_threshold, depth_threshold + 0.1, depth_diff);
	normal_diff = smoothstep(normal_threshold, normal_threshold + 0.1, normal_diff);
	lum_diff = smoothstep(brightness_threshold, brightness_threshold + 0.05, lum_diff) * brightness_strength;

	float total_outline = clamp(depth_diff + normal_diff + lum_diff, 0.0, 1.0);

	vec3 final_color = shadow_sample_color * shadow_color;

	ALBEDO = final_color;
	DEPTH = mix(center_depth_data.y, min_depth_data.y, total_outline);
	ALPHA = clamp(total_outline * 5.0, 0.0, 1.0);
}
