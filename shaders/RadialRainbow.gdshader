shader_type canvas_item;

uniform float speed: hint_range(0.0, 10.0) = 1.0;


vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec2 pos = vec2(0.5) - UV;
	COLOR.rgb = hsv2rgb(vec3( ((atan(pos.y, pos.x) - TIME * speed) / (TAU)), 1.0, 1.0));
}
