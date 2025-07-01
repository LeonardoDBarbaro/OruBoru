shader_type canvas_item;

uniform int digit : hint_range(0, 9) = 0; 
uniform vec2 led_count = vec2(16.0, 32.0); 
uniform float led_spacing = 1.5;
uniform float led_radius = 0.4;
uniform vec3 led_on_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 led_off_color : source_color = vec3(0.1, 0.1, 0.1);

// Devuelve si (x, y) dentro del área del número está encendido para ese dígito
int get_digit_pixel(int d, int x, int y) {
    // 3 columnas x 5 filas (x va de 0 a 2, y va de 0 a 4)
    if (d == 0) return int((x==0||x==2)&&y!=0 && y!=4 || (x==1 && (y==0 || y==4)));
    if (d == 1) return int((x==1 && y>=0 && y<=4));
    if (d == 2) return int((y==0 && x>0) || (y==1 && x==2) || (y==2 && x==1) || (y==3 && x==0) || (y==4));
    if (d == 3) return int((y==0 && x!=0) || (y==2 && x==1) || (y==4 && x!=0) || (x==2 && (y==1 || y==3)));
    if (d == 4) return int((y<=2 && x==0) || x==2 || (y==2));
    if (d == 5) return int((y==0) || (y==1 && x==0) || (y==2 && x==1) || (y==3 && x==2) || (y==4 && x!=2));
    if (d == 6) return int((x==0 && y>=1) || (x==1 && y==2) || (x==2 && (y==3 || y==4)) || (y==0 && x==1));
    if (d == 7) return int((y==0) || (x==2 && y>0));
    if (d == 8) return int((x==0 || x==2 || y==0 || y==2 || y==4));
    if (d == 9) return int((x==2 && y>=1) || (x==1 && y==2) || (x==0 && (y==0 || y==1)) || (y==0 || y==4));
    return 0;
}

void fragment() {
    vec2 uv = UV * led_count;
    ivec2 id = ivec2(floor(uv));
    vec2 grid_pos = fract(uv) - 0.5;

    float dist = length(grid_pos) * led_spacing;
    float led = step(dist, led_radius);

    int show = 0;

    // Centrado en la parte del medio
    if (id.x >= 6 && id.x < 9 && id.y >= 5 && id.y < 10) {
        int dx = id.x - 6;
        int dy = id.y - 5;
        show = get_digit_pixel(digit, dx, dy);
    }

    vec3 color = mix(led_off_color, led_on_color, float(show) * led);
    COLOR = vec4(color, 1.0);
}
