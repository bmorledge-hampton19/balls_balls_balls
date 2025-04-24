shader_type canvas_item;

uniform sampler2D noiseTexture: repeat_enable, filter_nearest;
uniform float density: hint_range(0.0, 1.0) = 0;

void vertex() {
	//VERTEX += vec2(cos(TIME)*10.0, sin(TIME)*10.0);
}

void fragment() {
	float distanceFromCenter = abs(0.5-UV.x);
	//COLOR.a = texture(noiseTexture, UV + vec2(0.05,0.05) * TIME).r;
	float gradualPlateau = (smoothstep(0.3,1.0,UV.y) - smoothstep(0.35,0.55,distanceFromCenter))*0.75;
	COLOR.a *= gradualPlateau * (abs(cos(TIME)) + 0.5);
	COLOR.rgb *= 0.75;
}
