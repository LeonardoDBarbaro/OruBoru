shader_type canvas_item;

/* ────────── Parámetros ────────── */
uniform float inner_radius      : hint_range(0.0, 0.5) = 0.28;
uniform float border_thickness  : hint_range(0.0, 0.5) = 0.08;
uniform float aa_width          : hint_range(0.0, 0.05) = 0.003;

/*  Desfase en grados: 90 ° = punta hacia arriba            */
uniform float angle_offset_deg  : hint_range(0.0,360.0) = 90.0;

/* ─ Colores ─ */
uniform vec4 center_color : source_color = vec4(0.20,0.60,1.00,1.0);
uniform vec4 slice0_color : source_color = vec4(1.00,0.40,0.40,1.0);
uniform vec4 slice1_color : source_color = vec4(1.00,0.80,0.40,1.0);
uniform vec4 slice2_color : source_color = vec4(0.40,1.00,0.40,1.0);
uniform vec4 slice3_color : source_color = vec4(0.40,0.80,1.00,1.0);
uniform vec4 slice4_color : source_color = vec4(0.80,0.40,1.00,1.0);

/* ────────── Aux ────────── */
vec4 get_slice_color(int slice) {
	if      (slice == 0) return slice0_color;
	else if (slice == 1) return slice1_color;
	else if (slice == 2) return slice2_color;
	else if (slice == 3) return slice3_color;
	else                 return slice4_color;
}

/* ────────── Fragment ────────── */
void fragment() {
	/* 1. Coordenadas centradas y corrección de aspecto */
	vec2  uv     = UV * 2.0 - 1.0;
	uv.x        *= TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y;

	/* 2. Distancias */
	float dist   = length(uv);
	float r_in   = inner_radius;
	float r_out  = inner_radius + border_thickness;

	/* 3. Ángulo normalizado + rotación ------------------------------------- */
	float angle      = atan(uv.y, uv.x);                   // −π … π
	float offset_rad = radians(angle_offset_deg);          // grados → rad
	float angle_norm = fract((angle + offset_rad + PI)     // 0 … 1  después de fract
	                         / (2.0 * PI));
	int   slice_idx  = int(floor(angle_norm * 5.0));       // 0-4

	/* 4. Coloreo según la región ------------------------------------------- */
	if (dist < r_in - aa_width) {
		COLOR = center_color;

	} else if (dist < r_in + aa_width) {
		float t = smoothstep(r_in + aa_width, r_in - aa_width, dist);
		COLOR   = mix(get_slice_color(slice_idx), center_color, t);

	} else if (dist < r_out - aa_width) {
		COLOR = get_slice_color(slice_idx);

	} else if (dist < r_out + aa_width) {
		float t = smoothstep(r_out - aa_width, r_out + aa_width, dist);
		COLOR   = mix(get_slice_color(slice_idx), vec4(0.0), t);

	} else {
		COLOR = vec4(0.0);
	}
}
