shader_type canvas_item;
render_mode blend_add;

uniform vec3 teamColor : source_color = vec3(1,1,1);

void fragment() {
	COLOR.a = COLOR.r;
	COLOR.rgb = teamColor;
}
