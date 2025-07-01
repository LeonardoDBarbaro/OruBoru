shader_type spatial;
render_mode depth_draw_always;
render_mode depth_prepass_alpha;

uniform float alpha = 1.0;
uniform vec3 albedo : source_color;

void fragment()
{
     ALBEDO = albedo.rgb;
     ALPHA = alpha;
}