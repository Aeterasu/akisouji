shader_type spatial;
render_mode cull_disabled, depth_prepass_alpha, depth_draw_opaque, specular_disabled;
//render_mode blend_mix, cull_disabled, depth_draw_opaque, specular_disabled;

uniform sampler2D Texture;

uniform float WindScale : hint_range(1.0, 20.0) = 1.0;
uniform float WindStrength : hint_range(1.0, 20.0) = 5.0;
uniform float WindDensity : hint_range(1.0, 20.0) = 5.0;
uniform float ClampTop : hint_range(0.0, 1.0) = 1.0;
uniform float ClampBtm : hint_range(-1.0, 0.0) = 0.0;
uniform float MeshScale : hint_range(-5.0, 5.0) = -0.333;

uniform vec4 FresnelColor : source_color = vec4(0.58, 0.65, 0.33, 1.0);
uniform float FresnelStrength : hint_range(-2.0, 2.0) = 0.5;
uniform float FresnelBlend : hint_range(-1.0, 1.0) = 1.0;

void vertex()
{
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;	//generate world coordinates for vertices

	vec3 orient_2d = vec3(1.0, 1.0, 0.0) - vec3(UV.x, UV.y, 0.0);
	orient_2d *= 2.0;
	orient_2d -= vec3(1.0, 1.0, 0.0);
	orient_2d *= -1.0;
	orient_2d *= MeshScale;

	//random tilt
	float angle = 6.248 * UV2.x;
	float cos_ang = cos(angle);
	float sin_ang = sin(angle);
	mat3 rotation = mat3(vec3(cos_ang, -sin_ang, 0.0),vec3(sin_ang, cos_ang, 0.0),vec3(0.0, 0.0, 0.0));

	orient_2d *= rotation;

	vec3 oriented_offset = reflect((INV_VIEW_MATRIX * vec4(orient_2d, 0.0)).xyz,INV_VIEW_MATRIX[0].xyz);
	//vec3 oriented_offset = (INV_VIEW_MATRIX * vec4(orient_2d, 0.0)).xyz;
	vec3 obj_oriented_offset = (vec4(oriented_offset, 0.0) * MODEL_MATRIX).xyz;

	//цind-Effect
	vec3 world_pos_eff = world_pos;	//Generates world coordinates for vertecies
	// Removed using world_position due to dragging bug
	float positional_influence = -VERTEX.x + VERTEX.z -world_pos_eff.x + world_pos_eff.z;
	float offset = fract(positional_influence * (1.0 / WindScale) + (TIME * WindScale/1000.0));	//generates linear curve that slides along vertecies in world space
	offset = min(1.0 - offset, offset);														//makes generated curve a smooth gradient
	offset = (1.0 - offset) * offset * 2.0;

	float t = TIME + sin(TIME + offset + cos(TIME + offset * WindStrength * 2.0) * WindStrength); //Generates noise in world space value

	//float mask = fract(v.y * wind_density) * v.y; //Generates vertical mask, so leaves on top move further than leaves on bottom
	//mask = clamp(mask, 0.0, 1.0);                 //Clamps mask

	float mask = clamp(VERTEX.y * WindDensity, 0.0, 1.0) * (ClampTop - ClampBtm) + ClampBtm;

	float si = sin(t) / 20.0 * WindStrength * offset;	//Generates clamped noise, adds strength, applies gradient mask
	float csi = cos(t)/ 20.0 * WindStrength * offset;	//Generates clamped noise with offset, adds strength, applies gradient mask

	vec3 wind_offset = vec3(VERTEX.x * si * mask, VERTEX.y * si * mask, VERTEX.z * csi * mask);

	COLOR = vec4(VERTEX.y, positional_influence, 0.0, 1.0);
	VERTEX += obj_oriented_offset + wind_offset;
}

void fragment()
{
	float rate_col1 = clamp(COLOR.r,0.0, 1.0);
	float rate_col2 = 1.0 - rate_col1;

	vec2 uv = clamp(UV, 0.0, 1.0);
	vec4 tex = texture(Texture, uv.xy).rgba;

	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	float fresnel_rate = clamp(rate_col1,0.1,1);

	vec3 fres_col = tex.rgb * (1.0 - FresnelStrength);
	fres_col += FresnelColor.rgb * FresnelStrength;
	fres_col *= fresnel;
	fres_col *= fresnel_rate;
	fres_col *= FresnelBlend;

	ALBEDO = tex.rgb;
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
	ALPHA = clamp(tex.a, 0.0, 1.0);
	ALPHA_SCISSOR_THRESHOLD = 0.5;

	EMISSION = fres_col;
}