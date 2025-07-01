shader_type spatial;

uniform float frequency = 10.0;
uniform float fuzziness = 0.2;
uniform vec3 color_a : source_color = vec3(0.0, 0.0, 1.0);
uniform vec3 color_b : source_color = vec3(1.0, 1.0, 0.0);

void fragment() {
    vec2 uv_centered = UV - vec2(0.5);
    float dist = length(uv_centered);
    float wave = sin(dist * frequency * PI * 2.0);

    // Suaviza la transición con smoothstep para efecto fuzzy
    float fuzzy_wave = smoothstep(-fuzziness, fuzziness, wave);

    vec3 color = mix(color_a, color_b, fuzzy_wave);
    
    ALBEDO = color;
}
