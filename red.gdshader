shader_type spatial;
render_mode unshaded, blend_mix;

uniform float golpe = 0.0;
uniform sampler2D texture_albedo;

void fragment() {
    vec4 tex_color = texture(texture_albedo, UV);
    ALBEDO = tex_color.rgb;
    ALPHA = tex_color.a;
}

void vertex() {
    if (golpe > 0.0) {
        VERTEX.z += sin(UV.x * 40.0 + TIME * 60.0) * golpe * 0.2;
        VERTEX.y += sin(UV.y * 40.0 + TIME * 60.0) * golpe * 0.1;
    }
}