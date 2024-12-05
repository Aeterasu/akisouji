shader_type canvas_item;

uniform float coeff = 1.0;
uniform vec4 modulate : source_color;

void fragment()
{
	vec4 baseColor = texture(TEXTURE, (UV * (1.0 + coeff) + vec2(coeff * -0.5, coeff * -0.5)));
	COLOR = modulate * baseColor;
}