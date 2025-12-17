shader_type canvas_item;

uniform float mix_amount : hint_range(0.0, 1.0) = 0.0;
// Soft Teal/Cyan tint for a "Spirit World" look. Very easy on the eyes.
uniform vec4 tint_color : source_color = vec4(0.3, 0.6, 0.7, 1.0); 

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	
	// Convert to grayscale using standard luminance weights
	float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	
	// Create the tinted version
	// We multiply the grayscale by our tint color
	vec3 targeted_color = vec3(gray) * tint_color.rgb;
	
	// Slight brightness boost to ensure visibility
	targeted_color *= 1.2;
	
	// Mix smoothly between original and new dimension
	COLOR = mix(color, vec4(targeted_color, color.a), mix_amount);
}
