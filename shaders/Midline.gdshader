shader_type canvas_item;

uniform float width = 10;
uniform float height = 540;

uniform float radius = 5;
uniform float distanceBetweenBalls = 15;

uniform float offset = 0.0;

void fragment() {
	vec2 ballPos = vec2(
		UV.x*width,
		mod(UV.y*height + offset, distanceBetweenBalls)
	);
	vec2 center = vec2(width/2.0, distanceBetweenBalls/2.0);
	float distanceFromCenter = sqrt(pow(ballPos.x-center.x,2) + pow(ballPos.y-center.y,2));

	COLOR.a *= 1.0-step(radius/2.0, distanceFromCenter) +
			   1.0-smoothstep(radius/2.0, radius, distanceFromCenter);
}
