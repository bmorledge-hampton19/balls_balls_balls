shader_type canvas_item;

uniform float elapsedTime = 0;
uniform float speed: hint_range(0.0, 1.0) = 0.5;
uniform float ballRadius = 0.0;

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec2 pos = vec2(0.5) - UV;
	float distanceFromCenter = sqrt(pow(pos.x,2) + pow(pos.y,2));
	float pulseStart = fract(1.0-elapsedTime*speed) - 0.02;
	float pulseEnd = fract(1.0-elapsedTime*speed) + 0.02;
	float pulsePos = smoothstep(pulseStart,pulseEnd,distanceFromCenter);
	float invertPulsePos = 1.0 - pulsePos;
	pulsePos *= (1.0-step(pulseEnd,distanceFromCenter));
	invertPulsePos *= step(pulseStart, distanceFromCenter);

	COLOR.rgb = hsv2rgb(vec3( (atan(pos.y, pos.x)+pulsePos/5.0)/TAU - TIME/10.0,
						smoothstep(ballRadius-0.1,0.5, distanceFromCenter),
						smoothstep(ballRadius-0.1,0.5, distanceFromCenter)));

	COLOR.a *= invertPulsePos;
}
