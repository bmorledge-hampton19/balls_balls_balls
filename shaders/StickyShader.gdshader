shader_type canvas_item;

uniform sampler2D noise: repeat_enable;
uniform float flipped = 0.0;
uniform float width = 100;
uniform vec2 noiseOffset = vec2(0,0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float edgeDamping = (0.25+0.75*smoothstep(0,0.1,UV.x)) * (1.0-smoothstep(0.9,1.0,UV.x)*0.75);
	float waveHeight = texture(noise, vec2(UV.x*width/1000.0+noiseOffset.x,
	                                       noiseOffset.y+TIME/500.0)).r*0.85*edgeDamping+0.1;
	COLOR.a *= 1.0-smoothstep(waveHeight-0.2,waveHeight+0.2, abs(flipped-UV.y));
	COLOR.r = (1.0-COLOR.r)*1.0;
	COLOR.g = (1.0-COLOR.g)*1.0;
	COLOR.b = (1.0-COLOR.b)*1.0;
}

