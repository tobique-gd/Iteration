shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_lambert, specular_schlick_ggx;

uniform float wind_strength = 0.25;
uniform float wind_speed = 1.5;

uniform float twist_strength = 0.08;

uniform vec3 wind_axis = vec3(1.0, 0.0, 0.0);

uniform sampler2D alb;

float hash(float x){
	return fract(sin(x * 127.1) * 43758.5453123);
}


mat3 rotation_by_axis(float angle, vec3 axis){

	axis = normalize(axis);

	float c = cos(angle);
	float s = sin(angle);

	return mat3(
		vec3(
			c + axis.x * axis.x * (1.0 - c),
			axis.x * axis.y * (1.0 - c) - axis.z * s,
			axis.x * axis.z * (1.0 - c) + axis.y * s
		),
		vec3(
			axis.y * axis.x * (1.0 - c) + axis.z * s,
			c + axis.y * axis.y * (1.0 - c),
			axis.y * axis.z * (1.0 - c) - axis.x * s
		),
		vec3(
			axis.z * axis.x * (1.0 - c) - axis.y * s,
			axis.z * axis.y * (1.0 - c) + axis.x * s,
			c + axis.z * axis.z * (1.0 - c)
		)
	);
}


void vertex() {

	vec3 original_vertex = VERTEX;

	float mask = UV.y;


	// random seed
	float seed = COLOR.g * 1290.0;

	float h1 = hash(seed);
	float h2 = hash(seed + 13.7);
	float h3 = hash(seed + 29.4);
	float h4 = hash(seed + 51.2);
	float h5 = hash(seed + 87.9);


	float phase = h1 * 100.0;

	float strength_variation =
		mix(0.7, 1.3, h2);

	float twist_variation =
		mix(0.6, 1.4, h3);

	float freq1 =
		mix(0.8, 1.3, h4);

	float freq2 =
		mix(0.6, 1.5, h5);


	// slightly different bend direction per tree
	vec3 varied_axis =
		normalize(
			wind_axis +
			vec3(
				h1 - 0.5,
				0.0,
				h2 - 0.5
			) * 0.4
		);


	float gust =
		sin(
			TIME * wind_speed * freq1 +
			phase +
			VERTEX.x * 0.4 +
			VERTEX.z * 0.4
		) * 0.5;


	gust +=
		sin(
			TIME * wind_speed * 0.73 * freq2 +
			phase * 1.7 +
			VERTEX.x * 1.3
		) * 0.25;


	gust +=
		sin(
			TIME * wind_speed * 1.2 * freq1 +
			phase * 3.0 +
			VERTEX.y * 8.0
		) * 0.05;


	// one-sided
	gust = gust * 0.5 + 0.5;
	gust = pow(gust, 2.0);


	float bend_angle =
		gust *
		wind_strength *
		strength_variation *
		mask;


	float twist =
		(
			sin(
				TIME * wind_speed * 1.9 * freq1 +
				phase +
				VERTEX.y * 4.0
			) +

			cos(
				TIME * wind_speed * 2.7 * freq2 +
				phase * 2.0 +
				VERTEX.x * 3.0
			)
		) *
		twist_strength *
		twist_variation *
		mask;


	mat3 bend_rotation =
		rotation_by_axis(
			bend_angle,
			varied_axis
		);


	mat3 twist_rotation =
		rotation_by_axis(
			twist,
			vec3(0.0, 1.0, 0.0)
		);


	VERTEX =
		original_vertex *
		twist_rotation *
		bend_rotation;
}

void fragment(){
	ALBEDO = vec3(0.8, 0.85, 0.85).rgb;

}