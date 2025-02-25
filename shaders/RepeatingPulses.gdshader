shader_type canvas_item;

uniform float speed: hint_range(0.0, 1.0) = 0.4;
uniform float pulseFrequency = 5.0;
uniform float pulseCoverage: hint_range(0.0, 1.0) = 0.25;

void fragment() {
	vec2 pos = vec2(0.5) - UV;
	float distanceFromCenter = sqrt(pow(pos.x,2) + pow(pos.y,2));
	float distanceFromPulseStart = mod(distanceFromCenter-fract(TIME*speed)/pulseFrequency,
									   1.0/pulseFrequency);
	COLOR.a *= 1.0-smoothstep(0, 1.0/pulseFrequency*pulseCoverage, distanceFromPulseStart);
	COLOR.a *= 1.0-distanceFromCenter*2.0;
}


