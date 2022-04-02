shader_type spatial;

render_mode unshaded, cull_disabled;

uniform vec4 color : hint_color = vec4(1.0);

void fragment() {
	vec3 world_coords = (CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	float vis = 1.0;
	
	if (mod(world_coords.y + world_coords.x + world_coords.z + TIME * 0.4, 0.6) > 0.03) {
		vis *= 0.2;
	}
	
	ALBEDO = color.xyz * vis;
	ALPHA = color.a * vis;
}
