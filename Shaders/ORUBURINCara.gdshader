shader_type spatial;
render_mode unshaded, depth_draw_never, cull_disabled;

uniform sampler2D texture_albedo;
uniform float max_angle = 1.57;

void fragment() {
    vec3 view_dir = normalize(CAMERA_POSITION - WORLD_POSITION).xyz;
    vec3 sprite_front = normalize((WORLD_MATRIX * vec4(0.0, 0.0, -1.0, 0.0)).xyz);

    float angle = acos(dot(view_dir, sprite_front));

    if (angle > max_angle) {
        discard;
    }

    ALBEDO = texture(texture_albedo, UV).rgb;
    ALPHA  = texture(texture_albedo, UV).a;
}
