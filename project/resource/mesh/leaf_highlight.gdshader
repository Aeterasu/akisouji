shader_type spatial;

render_mode unshaded, depth_test_disabled;

uniform vec4 highlight_color : source_color = vec4(1.0);
uniform sampler2D leaf_texture;

void vertex()
{
	COLOR = highlight_color * COLOR.a;
}

void fragment()
{
	vec4 tex = texture(leaf_texture, UV).rgba;
	ALBEDO = highlight_color.rgb;
	ALPHA = tex.a * COLOR.a;
}