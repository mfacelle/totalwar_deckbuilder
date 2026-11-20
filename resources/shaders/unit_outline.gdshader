shader_type canvas_item;

// modified by me, but shader code originally from: 
// https://godotshaders.com/shader/lightweight-pixel-perfect-outline/

uniform vec4 outline_color : source_color = vec4(0.29, 1.0, 0.84, 1.0);
uniform float line_thickness : hint_range(0, 10) = 1.0;

// blinking modulates the base color. set to 0 for no sprite blink
// not really any specific units, just check preview for how it looks
uniform vec4 blink_color : source_color = vec4(0.29, 1.0, 0.84, 1.0);
uniform float blink_time_scale : hint_range(0.0, 10.0, 0.1) = 0.0;

// if diagonal outline should also be drawn (makes it look chunkier)
uniform bool diagonal_outline = false;


void fragment() {
    vec2 pixel_size = TEXTURE_PIXEL_SIZE;
    
    // orthagonal neighbor pixels
    bool within = texture(TEXTURE, UV + line_thickness * pixel_size * vec2(1.0, 0.0)).a > 0.0;
    within = within || texture(TEXTURE, UV + line_thickness * pixel_size * vec2(0.0, -1.0)).a > 0.0;
    within = within || texture(TEXTURE, UV + line_thickness * pixel_size * vec2(0.0, 1.0)).a > 0.0;
    within = within || texture(TEXTURE, UV + line_thickness * pixel_size * vec2(-1.0, 0.0)).a > 0.0;
    
    if (diagonal_outline) 
    {
        // include diagonal neighbor pixels
        within = within || texture(TEXTURE, UV + line_thickness * pixel_size * vec2(1.0, 1.0)).a > 0.0;
        within = within || texture(TEXTURE, UV + line_thickness * pixel_size * vec2(1.0, -1.0)).a > 0.0;
        within = within || texture(TEXTURE, UV + line_thickness * pixel_size * vec2(-1.0, 1.0)).a > 0.0;
        within = within || texture(TEXTURE, UV + line_thickness * pixel_size * vec2(-1.0, -1.0)).a > 0.0;
    }
    
    bool outline = within && texture(TEXTURE, UV).a == 0.0;
    COLOR = mix(COLOR, COLOR * blink_color, 0.5 - 0.5 * cos(TIME * blink_time_scale));
    COLOR = float(!outline) * COLOR + float(outline) * outline_color;
}
