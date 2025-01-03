shader_type canvas_item;

uniform float width = 100;
uniform float height = 10;

float getInnerBorderAlpha(float len, float pos) {
	return smoothstep(2.5/len,4.5/len,pos) *
		   (1.0-smoothstep(1.0-4.5/len,1.0-2.5/len,pos)) *
		   step(2.5/len,pos) * (1.0-step(1.0-2.5/len,pos));
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
}
