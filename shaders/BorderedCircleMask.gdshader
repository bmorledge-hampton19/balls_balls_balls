shader_type canvas_item;

uniform float brightness = 0.5;
uniform float outerBoundary = 0.5;
uniform float innerBoundary = 0.45;

void fragment() {
	vec2 pos = vec2(0.5) - UV;
	float distanceFromCenter = sqrt(pow(pos.x,2) + pow(pos.y,2));
	float boundary = 0.5;
	COLOR.rgb *= smoothstep(innerBoundary-sin(TIME*2.0)*0.01, outerBoundary, distanceFromCenter);
	COLOR.a = 1.0-step(boundary, distanceFromCenter);

	//float curveFunc = (pos.y+0.02)-pow(pos.x,2);
	//float curveFunc = pos.x + pos.y;
	//float isValid = step(-0.001, curveFunc) * (1.0-step(0.001, curveFunc));
	//COLOR.r += 1.0*isValid;
}
