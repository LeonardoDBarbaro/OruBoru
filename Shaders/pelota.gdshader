shader_type spatial;

uniform sampler2D albedo_texture : source_color;
uniform vec3 velocity;
uniform float stretch_strength : hint_range(0.0, 10.0) = 5.0;
uniform float speed_min : hint_range(0.0, 100.0) = 5.0;
uniform float speed_max : hint_range(0.0, 100.0) = 25.0;

varying vec2 uv_shifted;

void vertex() {
	float speed = length(velocity);
	vec3 dir = speed > 0.01 ? normalize(velocity) : vec3(0.0);

	// Escala de distorsión solo si está cerca de la velocidad máxima
	float factor = smoothstep(speed_min, speed_max, speed);

	// Estiramos la geometría
	VERTEX += dir * VERTEX.z * stretch_strength * factor;

	// Estiramos las UVs también
	uv_shifted = UV + vec2(dir.x, dir.z) * stretch_strength * factor * 0.05;
}

void fragment() {
	ALBEDO = texture(albedo_texture, uv_shifted).rgb;
}
