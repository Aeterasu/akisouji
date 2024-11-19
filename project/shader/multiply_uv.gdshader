shader_type canvas_item;

uniform float speed;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment()
{
	vec4 baseColor = texture(TEXTURE, UV * 2.5);
	vec4 blendColor = texture(SCREEN_TEXTURE, SCREEN_UV);

	COLOR = baseColor * blendColor;
}