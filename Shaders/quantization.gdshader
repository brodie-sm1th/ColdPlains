shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest_mipmap, repeat_enable;
uniform float levels = 12.0;
uniform float colamt = 16.0;
uniform float ratio = 0.8;


void fragment() {
	
	vec3 frag_color = textureLod(screen_texture, UV, 0.0).rgb;
	vec3 col = frag_color;
	col = floor(col * colamt) / colamt;
	col *= 1. / (floor(.99 * colamt) / colamt);
	
	float greyscale = max(frag_color.r ,max(frag_color.g, frag_color.b));
	//float greyscale = max(col.r ,max(col.g, col.b));
	float lower = floor(greyscale * levels) / levels;
	float lower_diff = abs(greyscale - lower);
	float upper = ceil(greyscale * levels) / levels;
	float upper_diff = abs(upper - greyscale);
	float level = lower_diff <= upper_diff ? lower : upper;
	float adjustment = level / greyscale;
	COLOR.rgb = col * adjustment * ratio + frag_color * (1.0 - ratio);
}

