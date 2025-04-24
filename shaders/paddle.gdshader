shader_type canvas_item;

uniform float width = 100;
uniform float height = 10;

float getInnerBorderAlpha(float len, float pos) {
	return smoothstep(1.25/len,5.0/len,pos) *
		   (1.0-smoothstep(1.0-5.0/len,1.0-1.25/len,pos)) *
		   step(1.25/len,pos) * (1.0-step(1.0-1.25/len,pos));
}

float getMiddleBorderAlpha(float len, float pos) {
	return max(1.0-smoothstep(1.5/len,3.0/len,pos),
			   smoothstep(1.0-3.0/len,1.0-1.5/len,pos));
}

float getOuterBorderAlpha(float len, float pos) {
	return smoothstep(-0.5/len,1.5/len,pos) *
		   (1.0-smoothstep(1.0-1.5/len,1.0+0.5/len,pos));
}

void fragment() {
	float innerBorderAlpha = min(getInnerBorderAlpha(width, UV.x),
								 getInnerBorderAlpha(height, UV.y));
	float middleBorderAlpha = max(getMiddleBorderAlpha(width, UV.x),
								  getMiddleBorderAlpha(height, UV.y));
	float outerBorderAlpha = min(getOuterBorderAlpha(width, UV.x),
								 getOuterBorderAlpha(height, UV.y));

	COLOR.rgb *= innerBorderAlpha+middleBorderAlpha*outerBorderAlpha;
	//COLOR.rgb += 1.0-step(0.3, outerBorderAlpha);

	float whiteShift = smoothstep(0.8,1.0,innerBorderAlpha)*0.7;
	COLOR.r += (1.0-COLOR.r+0.2)*whiteShift;
	COLOR.g += (1.0-COLOR.g+0.2)*whiteShift;
	COLOR.b += (1.0-COLOR.b+0.2)*whiteShift;
}
