shader_type canvas_item;
render_mode unshaded, blend_mix, skip_vertex_transform;

uniform float num_lines = 20.0;
uniform float y_threshold = 0.5; // hint_range(0.0, 1.0)
uniform vec4 line_color_a = vec4(1.0); // hint_color
uniform vec4 line_color_b = vec4(0.0, 0.0, 0.0, 1.0); // hint_color

void fragment() {
	vec2 tiled_uv = vec2(fract(UV.x * num_lines / 2.0), UV.y);

	if (tiled_uv.x < 0.5) {
		if (tiled_uv.y < y_threshold) {
			COLOR = line_color_a;
		} else {
			COLOR = vec4(0.0);
		}
	} else {
		if (tiled_uv.y > 1.0 - y_threshold) {
			COLOR = line_color_b;
		} else {
			COLOR = vec4(0.0);
		}
	}
}
