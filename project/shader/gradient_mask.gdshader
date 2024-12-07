shader_type canvas_item;

uniform sampler2D mask;

void fragment()
{
	COLOR *= texture(mask, UV);
}