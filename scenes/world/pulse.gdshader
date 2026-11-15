
shader_type spatial;

uniform vec4 emission_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 completed_color : source_color = vec4(0.0, 0.8, 0.85, 1.0);

instance uniform float progress : hint_range(0.0, 1.0) = 0.0;

instance uniform float blink_speed = 12.0;
instance uniform float blink_intensity = 4.0;

instance uniform float min_intensity = 0.0;
instance uniform float max_intensity = 1.0;
instance uniform float flicker_amount = 0.25;

instance uniform float chaos_speed = 35.0;

// Completed state controls
instance uniform float pulse_speed = 1.5;
instance uniform float completed_intensity = 2.0;
instance uniform float completed_min_intensity = 0.7;

void fragment() {
    float blink = sin(TIME * blink_speed);
    blink = smoothstep(-0.2, 0.2, blink);

    float chaos = sin(TIME * chaos_speed)
                * sin(TIME * chaos_speed * 2.37);

    chaos *= flicker_amount;

    float red_intensity = mix(
        min_intensity,
        max_intensity,
        clamp(blink + chaos, 0.0, 1.0)
    );

    float pulse = (sin(TIME * pulse_speed) + 1.0) * 0.5;

    float teal_intensity = mix(
        completed_min_intensity,
        1.0,
        pulse
    );

    vec3 final_color = mix(
        emission_color.rgb,
        completed_color.rgb,
        progress
    );

    float final_intensity = mix(
        red_intensity * blink_intensity,
        teal_intensity * completed_intensity,
        progress
    );

    ALBEDO = final_color * 0.15;
    EMISSION = final_color * final_intensity;
}
