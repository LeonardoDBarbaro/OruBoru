shader_type canvas_item;

// Uniforms
uniform sampler2D screen_texture : hint_screen_texture;
uniform float grain_amount : hint_range(0.0, 1.0) = 0.05;
uniform float grain_size : hint_range(0.1, 10.0) = 1.0;
uniform float grain_speed : hint_range(0.0, 10.0) = 1.0; // Nueva variable para controlar la velocidad

void fragment() {
    // Sample the original screen texture
    vec4 original_color = texture(screen_texture, SCREEN_UV);

    // Crea una posición alterada con tiempo para hacer ruido dinámico
    vec2 moving_uv = UV * grain_size + vec2(TIME * grain_speed, TIME * grain_speed * 0.5);

    // Genera ruido con posición cambiante
    float noise = fract(sin(dot(moving_uv, vec2(12.9898, 78.233))) * 43758.5453);

    // Centra el ruido en torno a 0 y escala
    noise = (noise - 0.5) * 2.0;

    // Aplica el grano al color original
    original_color.rgb += noise * grain_amount;

    // Asegura que el color resultante esté entre 0 y 1
    COLOR = clamp(original_color, 0.0, 1.0);
}
