shader_type canvas_item;

const float width = 960.0;
const float height = 540.0;

uniform float distortionIntensity = 0.15;
uniform float distortionVariation = 0.2;
uniform float gridLineFrequency = 100.0;
uniform float gridLineWidth = 10.0;
uniform float gridLineXOffset = 45;
uniform float gridLineYOffset = 45;
uniform float gridSaturation = 0.5;

uniform vec2 centerOffset = vec2(0,0);
uniform float visibilityCutoff = 1.0;

void fragment() {
	//float distanceFromCenter = distance(vec2(0.5, 0.5), vec2(mix(0.5, UV.x, 1), UV.y));
	
	vec2 centerPos = UV - 0.5 + centerOffset;
	float distanceFromCenter = sqrt(pow(centerPos.x,2) + pow(centerPos.y*height/width,2));
	centerPos *= 1.0 - distortionIntensity *
				 (1.0+distortionVariation*sin(TIME)) *
				 pow(1.0-distanceFromCenter,2);
	
	float xpos = centerPos.x*width + gridLineXOffset;
	float ypos = centerPos.y*height + gridLineYOffset;

	float xGridStart = gridLineFrequency-gridLineWidth;
	float xModPos = mod(xpos, gridLineFrequency);
	float xColor = step(xGridStart, xModPos);
	xColor *= min(
		smoothstep(xGridStart, xGridStart + gridLineWidth/2.0, xModPos),
		1.0-smoothstep(xGridStart + gridLineWidth/2.0, xGridStart + gridLineWidth, xModPos)
	);

	float yGridStart = gridLineFrequency-gridLineWidth;
	float yModPos = mod(ypos, gridLineFrequency);
	float yColor = step(yGridStart, yModPos);
	yColor *= min(
		smoothstep(yGridStart, yGridStart + gridLineWidth/2.0, yModPos),
		1.0-smoothstep(yGridStart + gridLineWidth/2.0, yGridStart + gridLineWidth, yModPos)
	);

	COLOR.rgb = vec3(max(xColor,yColor)*gridSaturation);
	COLOR.a *= smoothstep(0.0,0.2, COLOR.r);
	COLOR.a *= 1.0-smoothstep(visibilityCutoff-0.05, visibilityCutoff+0.05, distanceFromCenter);
}
