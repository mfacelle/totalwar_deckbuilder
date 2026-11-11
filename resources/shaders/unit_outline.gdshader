shader_type canvas_item;

// got this from google search.  this is specifically from AI results,
// but linked source is here: https://godotshaders.com/shader/lightweight-pixel-perfect-outline/
// code in linked source is a bit different, though. worth investigating

uniform vec4 outline_color : source_color = vec4(0.29, 1.0, 0.84, 1.0);
uniform float line_thickness : hint_range(0, 10) = 1.0;

void fragment() {
	vec4 sprite_color = texture(TEXTURE, UV);
	if (sprite_color.a > 0.0) {
		COLOR = sprite_color;
	} else {
		// Sample neighboring pixels
		float alpha = 0.0;
		alpha += texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x * line_thickness, 0.0)).a;
		alpha += texture(TEXTURE, UV + vec2(-TEXTURE_PIXEL_SIZE.x * line_thickness, 0.0)).a;
		alpha += texture(TEXTURE, UV + vec2(0.0, TEXTURE_PIXEL_SIZE.y * line_thickness)).a;
		alpha += texture(TEXTURE, UV + vec2(0.0, -TEXTURE_PIXEL_SIZE.y * line_thickness)).a;
		
		if (alpha > 0.0) {
			COLOR = outline_color;
		} else {
			discard;
		}
	}
}