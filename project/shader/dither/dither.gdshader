shader_type canvas_item;

uniform sampler2D dither_texture;
uniform bool enabled = true;
uniform bool greyscale = false;
uniform float dither_amount = 1.0;
uniform int colours = 4;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float dither(float raw, float dither, int depth) {
	
	float div = 1.0 / float(depth);
	float val = 0.0;
	
	for (int i = 0; i < depth; i++) 
	{
		if (raw <= div * (float(i + 1))) 
		{
			if ((raw * float(depth)) - float(i) <= dither * 0.999) 
			{
				val = div * float(i);
			}
			else 
			{
				val = div * float(i + 1);
			}
			
			break;
		}
	}
	
	if (raw >= 1.0) 
	{
		val = 1.0;
	}
	
	return val;
}

void fragment() 
{
	vec4 raw = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec3 dither_pixel = texture(dither_texture, SCREEN_UV).rgb;
	
	if (enabled) 
	{
		if (greyscale)
		{
			raw.rgb = vec3((raw.r + raw.g + raw.b) / 3.0);
		}
		
		COLOR.r = dither(raw.r, (dither_pixel.x - 0.5) * dither_amount + 0.5, colours - 1);
		COLOR.g = dither(raw.g, (dither_pixel.x - 0.5) * dither_amount + 0.5, colours - 1);
		COLOR.b = dither(raw.b, (dither_pixel.x - 0.5) * dither_amount + 0.5, colours - 1);
	} 
	else 
	{
		COLOR.rgb = raw.rgb;
	}
	
	COLOR.a = raw.a;
}
