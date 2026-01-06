shader_type canvas_item;

uniform float radius = 32.0;
uniform vec2 size = vec2(256.0, 256.0);

uniform bool border_enabled = false;
uniform float border_width = 2.0;
uniform vec4 border_color : source_color = vec4(1.0);

float rounded_box(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
    vec2 center = size * 0.5;
    vec2 p = (UV * size) - center;
    vec2 half_size = size * 0.5;
    
    float dist = rounded_box(p, half_size, radius);
    
    float mask = smoothstep(1.0, 0.0, dist);
    
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 final_color = tex_color;
    
    if (border_enabled) {
        float border_mask = smoothstep(1.0, 0.0, dist + border_width);
        
        float border_factor = mask - border_mask;
        final_color.rgb = mix(tex_color.rgb, border_color.rgb, border_factor * border_color.a);
        
        final_color.a = max(tex_color.a, border_factor * border_color.a);
    }
    
    COLOR = vec4(final_color.rgb, final_color.a * mask);
}
