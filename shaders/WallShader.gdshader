shader_type canvas_item;

uniform sampler2D noise: repeat_enable;
uniform float width = 370;
uniform float flipped = 0.0;
uniform vec2 noiseOffset = vec2(0,0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float edgeDamping = (0.25+0.75*smoothstep(0,0.1,UV.x)) * (1.0-smoothstep(0.9,1.0,UV.x)*0.75);
	float waveHeight = texture(noise, vec2(UV.x*width/1100.0+noiseOffset.x,
	                                       TIME/10.0+noiseOffset.y)).r*
					   0.6*edgeDamping+0.2;
	waveHeight *= edgeDamping;
	COLOR.a = 1.0-smoothstep(waveHeight-0.2,waveHeight+0.2, abs(flipped-UV.y));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
