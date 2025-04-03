shader_type canvas_item;

uniform float width = 10;
uniform float height = 54;

float getInnerBorderAlpha(float len, float pos, float borderMid) {
	float innerBorderStart = borderMid - 0.5;
	float innerBorderEnd = borderMid + 1.5;
	return smoothstep(innerBorderStart/len,innerBorderEnd/len,pos) *
		   (1.0-smoothstep(1.0-innerBorderEnd/len,1.0-innerBorderStart/len,pos)) *
		   step(innerBorderStart/len,pos) * (1.0-step(1.0-innerBorderStart/len,pos));
}

float getMiddleBorderAlpha(float len, float pos, float borderMid) {
	float middleBorderStart = borderMid - 1.5;
	return max(1.0-smoothstep(middleBorderStart/len,borderMid/len,pos),
			   smoothstep(1.0-borderMid/len,1.0-middleBorderStart/len,pos));
}

float getOuterBorderAlpha(float len, float pos) {
	return smoothstep(-0.5/len,1.5/len,pos) *
		   (1.0-smoothstep(1.0-1.5/len,1.0+0.5/len,pos));
}

void fragment() {
	float borderMid = 6.0 - 6.0*fract(TIME/2.0);
	float innerBorderAlpha = min(getInnerBorderAlpha(width, UV.x, borderMid),
								 getInnerBorderAlpha(height, UV.y, borderMid));
	float middleBorderAlpha = max(getMiddleBorderAlpha(width, UV.x, borderMid),
								  getMiddleBorderAlpha(height, UV.y, borderMid));
	float outerBorderAlpha = min(getOuterBorderAlpha(width, UV.x),
								 getOuterBorderAlpha(height, UV.y));

	COLOR.rgb *= innerBorderAlpha+middleBorderAlpha*outerBorderAlpha;
}
