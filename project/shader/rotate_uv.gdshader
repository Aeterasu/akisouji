shader_type canvas_item;

render_mode unshaded, blend_add;

uniform sampler2D spin_texture;
uniform vec4 color : source_color;
uniform bool clockwise = true;
uniform float speed : hint_range(0.0, 2.0) = 1.0;

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
			vec2(cos(angle), sin(angle)));
    
    uv -= pivot;
    uv = uv * rotation;
    uv += pivot;
    return uv;
}

void fragment()
{
	COLOR = vec4(1.0);
	float direction = clockwise ? 1.0 : -1.0;
	vec2 rotated_uv = rotate(UV, vec2(0.5), TIME * speed * direction);
	COLOR = color * texture(spin_texture, rotated_uv);
}