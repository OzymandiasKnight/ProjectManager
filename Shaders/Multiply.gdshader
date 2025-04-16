shader_type canvas_item;

uniform float value = 0.5;
uniform vec4 color : source_color;

void fragment() {
	COLOR = texture(TEXTURE,UV);
	COLOR.r *= color.r*value;
	COLOR.g *= color.g*value;
	COLOR.b *= color.b*value;
	
	
}