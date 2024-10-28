shader_type canvas_item;

uniform vec4 modulate : source_color;

void fragment()
{
	 vec2 distortedUV = UV;
	distortedUV.y += sin(distortedUV.x * 8.0 + TIME*1.8) * 0.02;
	COLOR = texture(TEXTURE, distortedUV) * modulate;
}