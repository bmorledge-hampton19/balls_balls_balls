shader_type canvas_item;
render_mode blend_add;

uniform float pulseSpeed = 1.0;
uniform float randomPulseOffset = 0;

void fragment() {
	float distanceFromCenter = distance(vec2(0.5, 0.5), vec2(mix(0.5, UV.x, 1), UV.y));
	float colorMult = 1.0;
	float pulseOffset = sin(TIME*pulseSpeed+randomPulseOffset)*0.05;
	colorMult *= 1.0-smoothstep(0.35,0.45+pulseOffset,distanceFromCenter);
	colorMult *= (1.0-smoothstep(0.0, 0.35+pulseOffset, distanceFromCenter))*0.5 + 
				 step(0.35, distanceFromCenter);
	
	COLOR.rgb *= colorMult;
	
}