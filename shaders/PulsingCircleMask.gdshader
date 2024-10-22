shader_type canvas_item;

uniform float circle_size : hint_range(0.0, 1.0) = 0.4;
uniform float pulseStart : hint_range(0.0, 1.0) = 0.3;
uniform float pulseMin : hint_range(0.0, 1.0) = 0.4;
uniform float pulseMax : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	float dist = distance(vec2(0.5, 0.5), vec2(mix(0.5, UV.x, 1), UV.y));
	vec4 orig_color = texture(TEXTURE, UV);
	float meanPulse = (pulseMax + pulseMin) / 2.0;
	float pulseDeviation = meanPulse-pulseMin;
	float pulseCurrent = meanPulse + cos(TIME*2.0)*pulseDeviation;
	float alpha_total = (1.0 - smoothstep(pulseStart, pulseCurrent, dist));
	COLOR.a = alpha_total * orig_color.a;
}