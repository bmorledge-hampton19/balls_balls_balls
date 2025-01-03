shader_type canvas_item;

uniform float elapsedTime = 0;
uniform float speed: hint_range(0.0, 1.0) = 1.0;


vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec2 pos = vec2(0.5) - UV;
	float distanceFromCenter = sqrt(pow(pos.x,2) + pow(pos.y,2));
	COLOR.rgb = hsv2rgb(vec3(distanceFromCenter+TIME/PI, 1, 1));
	float pulseStart = fract(elapsedTime*speed) - 0.025;
	float pulseEnd = fract(elapsedTime*speed) + 0.025;
	COLOR.a = 1.0-distanceFromCenter*2.0;
	COLOR.a *= step(pulseStart, distanceFromCenter);
	COLOR.a *= 1.0-step(pulseEnd, distanceFromCenter);
}


