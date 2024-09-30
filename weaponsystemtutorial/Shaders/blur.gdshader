shader_type canvas_item;

uniform float blur : hint_range(0.0, 2.5);
uniform float brightness : hint_range(0.0, 1.0);

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	COLOR = textureLod(screen_texture, SCREEN_UV, blur);
	COLOR.rgb *= brightness;
}