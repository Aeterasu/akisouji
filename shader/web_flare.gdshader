shader_type canvas_item;
render_mode blend_add;

#include "res://shader/CLREDIT.gdshaderinc"

uniform lowp sampler2D Screen_Sample : hint_screen_texture, filter_linear_mipmap_anisotropic;
uniform lowp sampler2D FlareMult;
uniform lowp sampler2D FlareMult2;

uniform float Blur = 2.5;
uniform float FlareThreshold;
uniform int Flares;
uniform float FlareSpacing;

uniform float Intensity;
uniform float Saturation_;

vec4 texture_xorgaussian(sampler2D tex, vec2 uv, vec2 pixel_size, float blurriness, int iterations, int quality)
{
	float pi = 6.28;
	
	vec2 radius = blurriness / (1.0 / pixel_size).xy;
	vec4 blurred_tex = texture(tex, uv);
	
	for(float d = 0.0; d < pi; d += pi / float(iterations)){
		for( float i = 1.0 / float(quality); i <= 1.0; i += 1.0 / float(quality) ){
			vec2 directions = uv + vec2(cos(d), sin(d)) * radius * i;
			blurred_tex += texture(tex, directions);
		}
	}
	blurred_tex /= float(quality) * float(iterations) + 1.0;
	
	return blurred_tex;
}

void fragment(){
	vec2 FlippedUV = vec2(1.0) - SCREEN_UV;
	vec2 FlareVector = (vec2(0.5) - SCREEN_UV) * FlareSpacing;
	vec3 FinalFlare = vec3(0.0);

	for (int i = 0; i < Flares; ++i)
	{
		vec2 SUV = fract(SCREEN_UV + FlareVector * vec2(float(i)));
		float Dist = distance(SUV, vec2(0.5));
		float Weight = 1.0 - smoothstep(0.0, 0.75, Dist);
		//vec3 BlurredScreen = texture(Screen_Sample, SUV).rgb;
		vec3 BlurredScreen = texture_xorgaussian(Screen_Sample, SUV, SCREEN_PIXEL_SIZE, 16.0, 16, 4).rgb;
		BlurredScreen = ApplyThreshold(BlurredScreen, FlareThreshold);
		FinalFlare += BlurredScreen * Weight;
	}
	
	FinalFlare *= texture(FlareMult, SCREEN_UV).rgb;
	FinalFlare *= texture(FlareMult2, SCREEN_UV).rgb;
	COLOR.rgb = FinalFlare * Intensity;
	COLOR.rgb = Saturation(COLOR.rgb, Saturation_);
}