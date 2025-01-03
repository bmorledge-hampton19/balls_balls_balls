shader_type canvas_item;

uniform float spiralFrequency = 5.0;
uniform float spiralSkew = 3.0;
uniform float spiralRotationSpeed = 0.5;
uniform float reverse = 1.0;
uniform float spiralContrast = 0.6;
uniform float innerSpiralProgress = 0.5;

void fragment() {

	float distanceFromCenter = distance(vec2(0.5, 0.5), vec2(mix(0.5, UV.x, 1), UV.y));
	vec2 centerPos = UV-0.5;

	float positiveSpin = fract((atan(centerPos.y, centerPos.x)+
								distanceFromCenter*spiralSkew*reverse-
								TIME*spiralRotationSpeed*reverse)*spiralFrequency/PI);
	float negativeSpin = fract((atan(-centerPos.y, centerPos.x)-
								distanceFromCenter*spiralSkew*reverse+
								TIME*spiralRotationSpeed*reverse)*spiralFrequency/PI);
	float innerSpiral = 1.0-pow(positiveSpin*negativeSpin,spiralContrast);
	innerSpiral = smoothstep(0.6,0.8,innerSpiral);

	float visibleDistanceCenter = (1.0-innerSpiralProgress)/2.0;
	float visibleDistanceMin = visibleDistanceCenter - 0.1;
	float visibleDistanceMax = visibleDistanceCenter + 0.1;
	float visibility = smoothstep(visibleDistanceMin,visibleDistanceMax,distanceFromCenter)*
					   (1.0-smoothstep(visibleDistanceMin,visibleDistanceMax,distanceFromCenter));
	visibility *= 3.0;

	//COLOR.a = fract(atan(centerPos.x, centerPos.y)*(5.0+distanceFromCenter));
	COLOR.a = innerSpiral*visibility*(1.0-smoothstep(0.3,0.5,distanceFromCenter));

}
