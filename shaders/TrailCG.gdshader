shader_type canvas_item;
render_mode blend_premul_alpha;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {

	// Necessary for CanvasGroup
	COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);
	
}