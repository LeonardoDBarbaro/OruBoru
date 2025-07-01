shader_type spatial;

render_mode blend_mix, cull_disabled, specular_schlick_ggx;

uniform vec4 clay_color : source_color = vec4(1.0, 0.5, 0.3, 1.0);
uniform float bump_strength : hint_range(0.0, 1.0) = 0.2;
uniform float noise_scale : hint_range(0.1, 10.0) = 3.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.8;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 pos) {
    vec2 i = floor(pos);
    vec2 f = fract(pos);
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void fragment() {
    vec2 uv_noise = UV * noise_scale;
    float bump = (noise(uv_noise) - 0.5) * 2.0 * bump_strength;

    ALBEDO = clay_color.rgb;
    ROUGHNESS = roughness;
    METALLIC = metallic;

    // Microbump en la normal
    NORMAL = normalize(NORMAL + vec3(0.0, 0.0, bump));
}
