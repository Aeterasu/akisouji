shader_type canvas_item;

uniform float base = 1.0;
uniform float coeff = 0.1;
uniform float speed = 1.0;
uniform vec4 modulate : source_color;

void fragment()
{
	float a = base + cos(TIME * speed) * coeff;
	vec4 baseColor = texture(TEXTURE, (UV * (1.0 + a) + vec2(a * -0.5, a * -0.5)));
	COLOR = modulate * baseColor;
}