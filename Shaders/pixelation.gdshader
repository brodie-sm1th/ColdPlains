shader_type canvas_item;

uniform int pixel_size = 2;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 col;
	col = textureLod(screen_texture, UV, 0.0).rgb;
	COLOR.rgb = col;
	
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
