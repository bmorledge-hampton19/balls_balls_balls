shader_type canvas_item;

uniform float speed: hint_range(0.0, 1.0) = 0.25;
uniform float extraSaturation: hint_range(-1.0, 1.0) = 0;
uniform float value: hint_range(0.0, 1.0) = 1.0;

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec2 pos = vec2(0.5) - UV;
	float distanceFromCenter = sqrt(pow(pos.x,2) + pow(pos.y,2));
	COLOR.rgb = hsv2rgb(vec3(distanceFromCenter - TIME * speed,
							 value, distanceFromCenter+0.1+extraSaturation));
	COLOR.a = 1.0 - step(0.5, distanceFromCenter);
}
