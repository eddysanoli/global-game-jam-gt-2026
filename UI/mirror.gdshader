shader_type canvas_item;

uniform  vec4 CAST_COLOR : source_color;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

uniform sampler2D fast_noise: repeat_enable;

uniform float scale_y;
uniform float y_zoom;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV * TIME;
	
	//vec2 noise = texture(fast_noise, uv).rg;
	
	float uv_height = (SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y);
	
	vec2 reflected_uv = vec2(SCREEN_UV.x, SCREEN_UV.y - (uv_height * UV.y * scale_y * y_zoom));
	
	vec4 reflection = texture(SCREEN_TEXTURE, reflected_uv);
	
	COLOR = reflection + CAST_COLOR;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
