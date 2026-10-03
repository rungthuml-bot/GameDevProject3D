shader_type canvas_item;

// Main Menu cinematic overlay
// - Left-side dark gradient (keeps menu text readable over the 3D world)
// - Soft bottom / top fade
// - Subtle vignette
// Pure procedural: no screen texture, works with the Compatibility renderer.

uniform vec4 shade_color : source_color = vec4(0.045, 0.035, 0.03, 1.0);

uniform float left_strength : hint_range(0.0, 1.0) = 0.82;
uniform float left_extent : hint_range(0.05, 1.0) = 0.62;

uniform float bottom_strength : hint_range(0.0, 1.0) = 0.55;
uniform float top_strength : hint_range(0.0, 1.0) = 0.30;

uniform float vignette_strength : hint_range(0.0, 1.0) = 0.55;
uniform float vignette_radius : hint_range(0.1, 1.0) = 0.45;
uniform float vignette_softness : hint_range(0.05, 1.0) = 0.55;

void fragment() {
	vec2 uv = UV;

	// Left gradient: strongest at the left edge, fades out toward the subject
	float left = left_strength * (1.0 - smoothstep(0.0, left_extent, uv.x));

	// Bottom + top cinematic fade
	float bottom = bottom_strength * smoothstep(0.55, 1.0, uv.y);
	float top = top_strength * (1.0 - smoothstep(0.0, 0.28, uv.y));

	// Vignette (aspect-corrected so it stays round-ish on wide screens)
	vec2 d = uv - vec2(0.5);
	d.x *= 1.35;
	float vig = vignette_strength * smoothstep(vignette_radius, vignette_radius + vignette_softness, length(d));

	// Combine as layered darkening
	float a = 1.0 - (1.0 - left) * (1.0 - bottom) * (1.0 - top) * (1.0 - vig);
	COLOR = vec4(shade_color.rgb, clamp(a, 0.0, 1.0));
}
