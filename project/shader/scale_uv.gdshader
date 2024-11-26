shader_type canvas_item;

uniform float coeff = 1.0;

void fragment()
{
	vec4 baseColor = texture(TEXTURE, UV * coeff);
	COLOR = baseColor;
}