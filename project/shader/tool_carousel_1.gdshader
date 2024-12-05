shader_type canvas_item;

uniform sampler2D mask;
uniform vec4 modulate : source_color = vec4(1.0);

void fragment()
{
	COLOR = texture(TEXTURE, UV);
	
	vec2 muv = UV;
	muv.y = 1.0 - muv.y;
	COLOR *= texture(mask, muv);
	COLOR *= modulate;
}