shader_type canvas_item;

uniform float brightness = 0.5;

void fragment() {
	vec2 pos = vec2(0.5) - UV;
	float distanceFromCenter = sqrt(pow(pos.x,2) + pow(pos.y,2));
	float circleValue = (1.0-(distanceFromCenter-sin(TIME)*0.05)*2.0)*brightness;
	float boundary = 0.4 + sin(TIME)*0.05;
	COLOR.rgb *= circleValue*(1.0-step(boundary,distanceFromCenter));
	COLOR.a = 1.0-step(boundary, distanceFromCenter);

	//float curveFunc = (pos.y+0.02)-pow(pos.x,2);
	//float curveFunc = pos.x + pos.y;
	//float isValid = step(-0.001, curveFunc) * (1.0-step(0.001, curveFunc));
	//COLOR.r += 1.0*isValid;
}
