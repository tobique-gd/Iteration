
shader_type spatial;

instance uniform vec3 emission_color = vec3(1.0, 1.0, 1.0);
instance uniform float emission_strength = 0.0;
instance uniform vec3 albedo_color = vec3(1.0, 1.0, 1.0);

instance uniform float center_darkness = 0.35;
instance uniform float fade_radius = 2.0;

instance uniform float pulse_speed = 2.0;
instance uniform float pulse_strength = 0.15;

varying vec3 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec3 gradient_center = NODE_POSITION_WORLD;

    float dist = distance(world_position, gradient_center);

    float gradient = smoothstep(0.0, fade_radius, dist);

    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;

    float darkness = center_darkness + pulse * pulse_strength;

    float brightness = mix(1.0 - darkness, 1.0, gradient);

    ALBEDO = albedo_color * brightness;
    EMISSION = emission_color * emission_strength * brightness;
}
