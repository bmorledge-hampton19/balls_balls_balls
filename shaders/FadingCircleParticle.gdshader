shader_type canvas_item;

uniform float fadeStartRadius : hint_range(0.0, 1.0) = 0.35;
uniform float fadeEndRadius : hint_range(0.0, 1.0) = 0.5;

uniform float lifetimeFadeStart : hint_range(0.0, 1.0) = 0.3;
uniform float lifetimeFadeEnd : hint_range(0.0, 1.0) = 1.0;

varying flat float lifetime;

void vertex() {lifetime = INSTANCE_CUSTOM.y;}

void fragment() {
	float dist = distance(vec2(0.5, 0.5), vec2(mix(0.5, UV.x, 1), UV.y));
	COLOR.a *= (1.0 - smoothstep(fadeStartRadius, fadeEndRadius, dist));
	COLOR.a *= 1.0-smoothstep(lifetimeFadeStart,lifetimeFadeEnd,lifetime);
}