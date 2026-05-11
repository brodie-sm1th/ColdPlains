shader_type canvas_item;

uniform int pixel_size = 2;
uniform ivec2 screen_ratio = ivec2(16, 9);
uniform int screen_size = 20;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest_mipmap, repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 col;
	vec3 unmodified = textureLod(screen_texture, UV, 0.0).rgb;
	vec2 screen_pos = floor(UV * vec2(screen_ratio * screen_size)) + 0.5;
	vec2 pos = screen_pos / vec2(screen_ratio * screen_size);
	col = textureLod(screen_texture, pos, 0.0).rgb;
	vec3 bloom = textureLod(screen_texture, pos, 4.0).rgb;
	COLOR.rgb = clamp(pow(bloom + 0.1, vec3(2)) - 0.5, vec3(0), vec3(1)) + col;
	
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
