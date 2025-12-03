// Couldn't quite get this to work how I wanted...
// Would maybe be more doable with nested Canvas groups?
shader_type canvas_item;

uniform float startTime;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    vec4 background = texture(screen_texture, SCREEN_UV, 0.0);
	vec2 pos = vec2(0.5) - UV;
	float distanceFromCenter = sqrt(pow(pos.x,2) + pow(pos.y,2));

	float expansionRadius = pow(fract(TIME*0.25-startTime),2)/sqrt(2);
	float compressionRatio = expansionRadius/sqrt(2);
	vec2 compressedPos = pos/vec2(compressionRatio);
	COLOR = texture(screen_texture, SCREEN_UV, 0.0);

	COLOR.rgb *= 1.0-step(expansionRadius, distanceFromCenter);

}

