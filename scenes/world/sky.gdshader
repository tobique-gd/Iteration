shader_type sky;


group_uniforms colors;
uniform vec3 sky_top : source_color = vec3(0.60, 0.64, 0.70);
uniform vec3 sky_horizon : source_color = vec3(0.85, 0.87, 0.90);
uniform vec3 cloud_light : source_color = vec3(0.92, 0.93, 0.95);
uniform vec3 cloud_dark : source_color = vec3(0.50, 0.54, 0.60);

group_uniforms clouds;
uniform float cloud_scale : hint_range(0.2, 6.0) = 1.4;
uniform float coverage : hint_range(0.0, 1.0) = 0.7;
uniform float softness : hint_range(0.01, 0.5) = 0.15;
uniform float warp_strength : hint_range(0.0, 2.0) = 0.6;
uniform float horizon_fade : hint_range(0.01, 0.6) = 0.2;

group_uniforms stylization;
uniform int bands : hint_range(1, 8) = 3;
uniform float band_softness : hint_range(0.0, 0.5) = 0.08;
uniform vec2 light_dir = vec2(0.6, 0.4);
uniform float shade_contrast : hint_range(0.5, 10.0) = 4.0;

group_uniforms wind;
uniform float wind_speed : hint_range(0.0, 0.2) = 0.01;
uniform vec2 wind_dir = vec2(1.0, 0.3);

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 5; i++) {
		v += a * vnoise(p);
		p = p * 2.03 + vec2(17.1, 9.2);
		a *= 0.5;
	}
	return v;
}

float toon(float x, int steps, float soft) {
	float s = float(steps);
	float scaled = x * s;
	float base = floor(scaled);
	float f = fract(scaled);
	return (base + smoothstep(0.5 - soft, 0.5 + soft, f)) / s;
}

void sky() {
	vec3 dir = EYEDIR;
	float h = dir.y;

	vec3 base = mix(sky_horizon, sky_top, smoothstep(0.0, 0.7, h));

	float t = TIME * wind_speed;
	vec2 uv = dir.xz / (max(h, 0.0) + 0.25) * cloud_scale;
	uv += normalize(wind_dir) * t;

	vec2 warp = vec2(fbm(uv * 0.6 + t * 0.5), fbm(uv * 0.6 + 7.3 - t * 0.5));
	uv += (warp - 0.5) * warp_strength;

	float n = fbm(uv);

	float thr = 1.0 - coverage;
	float density = smoothstep(thr - softness, thr + softness, n);

	vec2 ld = normalize(light_dir + vec2(1e-4));
	float n_off = fbm(uv + ld * 0.12);
	float shade = clamp((n - n_off) * shade_contrast + 0.5, 0.0, 1.0);
	shade = toon(shade, bands, band_softness);

	float thickness = smoothstep(thr, thr + 0.35, n);
	vec3 cloud_col = mix(cloud_dark, cloud_light, shade);
	cloud_col = mix(cloud_col, cloud_dark, thickness * 0.35);

	float fade = smoothstep(0.0, horizon_fade, h);

	COLOR = mix(base, cloud_col, density * fade);
}