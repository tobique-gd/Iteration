
shader_type spatial;
render_mode diffuse_toon, specular_toon;

group_uniforms Shader.Albedo;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform sampler2D albedo_texture;

group_uniforms Shader.Light;
uniform bool use_stepped = true;
uniform float steps = 3.0;
uniform float step_smoothness : hint_range(0.0, 1.0, 0.05) = 0.3;
uniform vec4 shadow_tint : source_color;
uniform float shadow_tint_amount : hint_range(0.0, 1.0, 0.1) = 0.4;

group_uniforms Shader.Specular;
uniform float specular : hint_range(0.0, 1.0, 0.05) = 0.0;

group_uniforms Shader.Normal;
uniform float normal_strength : hint_range(0.0, 1.0, 0.05) = 0.0;
uniform sampler2D normal_texture;

void fragment() {
	vec4 albedo = texture(albedo_texture, UV) * albedo_color;
	vec4 normal_map = texture(normal_texture, UV);

	ALBEDO = albedo.rgb;

	NORMAL_MAP = mix(vec3(0.5, 0.5, 1.0), normal_map.rgb, normal_strength);

	SPECULAR = specular;
}

void light() {
    float ndotl = max(dot(NORMAL, LIGHT), 0.0) * ATTENUATION;

    float cel_mask = step(0.5, ndotl);

    vec3 shadow_color = shadow_tint.rgb;
    vec3 light_color = LIGHT_COLOR / PI;

    vec3 diffuse = mix(shadow_color, light_color, cel_mask);

    DIFFUSE_LIGHT += diffuse;

 
    vec3 half_vector = normalize(VIEW + LIGHT);
    float specular_dot = max(dot(NORMAL, half_vector), 0.0);

    float highlight = step(0.85, specular_dot);
    highlight *= specular * ATTENUATION;

    SPECULAR_LIGHT += vec3(highlight);
	
	
}
