shader_type canvas_item;

void fragment() {
	COLOR.a *= 1.0-smoothstep(0, 0.75 + 0.25*sin(TIME),1.0-UV.x);
}
