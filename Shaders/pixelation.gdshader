shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest_mipmap, repeat_enable;
uniform ivec2 screen_ratio = ivec2(16, 9);
uniform int screen_size = 20;
uniform float ratio = 0.6;


void fragment() {
	vec3 col;
	vec3 unmodified = textureLod(screen_texture, UV, 0.0).rgb;
	vec2 screen_pos = floor(UV * vec2(screen_ratio * screen_size)) + 0.5;
	vec2 pos = screen_pos / vec2(screen_ratio * screen_size);
	col = textureLod(screen_texture, pos, 0.0).rgb;
	
	vec2 screen_pos_2x = floor(UV * vec2(screen_ratio * screen_size * 2)) + 0.5;
	vec2 pos_2x = screen_pos_2x / vec2(screen_ratio * screen_size * 2);
	vec3 double_res = textureLod(screen_texture, pos_2x, 0.0).rgb;
	
	vec3 bloom = textureLod(screen_texture, pos, 2.0).rgb;
	COLOR.rgb = (clamp(pow(bloom + 0.1, vec3(2)) - 0.5, vec3(0), vec3(1)) + col) * ratio + double_res * (1.0 - ratio);
	
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
