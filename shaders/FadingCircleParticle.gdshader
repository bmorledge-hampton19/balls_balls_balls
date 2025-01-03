shader_type canvas_item;

uniform float fadeStart : hint_range(0.0, 1.0) = 0.35;
uniform float fadeEnd : hint_range(0.0, 1.0) = 0.5;

varying flat float lifetime;

void vertex() {lifetime = INSTANCE_CUSTOM.y;}

void fragment() {
	float dist = distance(vec2(0.5, 0.5), vec2(mix(0.5, UV.x, 1), UV.y));
	COLOR.a = (1.0 - smoothstep(fadeStart, fadeEnd, dist));
	COLOR.a *= 1.0-smoothstep(0.3,1,lifetime);
}