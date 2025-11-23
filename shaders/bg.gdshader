shader_type canvas_item;

uniform float tile_size = 100.0;
uniform float time_scale = 0.2;
uniform float mean_brightness = 0.3;

// Player reactive effect
uniform vec2 player_pos;
uniform float influence_radius = 150.0;
uniform float contrast_strength = 0.5;

float random(vec2 n) {
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

vec3 hsv2rgb(vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0), 6.0)-3.0)-1.0, 0.0, 1.0);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

void fragment() {
    vec2 tile = floor((UV / SCREEN_PIXEL_SIZE) / tile_size);
	// vec2 maxTile = floor(1.0 / (tile_size * SCREEN_PIXEL_SIZE));
	float r = random(tile);
	
	float radius = mix(0.02, 0.03, r);
	
	float brightness = mean_brightness + radius * sin(TIME * time_scale * mix(0.2, 0.9, r) + r);
    float hue = mod(TIME * time_scale * 0.03 + mix(0.0, 0.06, r), 1.0);
	float saturation = 0.3 + 0.15 * sin(TIME * time_scale * r * 0.1);

    vec3 color = hsv2rgb(vec3(hue, saturation, brightness));
	COLOR = vec4(color, 1);

    /*float px_dist = distance(SCREEN_UV * SCREEN_PIXEL_SIZE, player_pos);

    float influence = smoothstep(influence_radius, 0.0, px_dist);
    vec3 contrast_color = vec3(1.0) - color;

    color = mix(color, contrast_color, influence * contrast_strength);

    COLOR = vec4(color, 1.0);*/
}
