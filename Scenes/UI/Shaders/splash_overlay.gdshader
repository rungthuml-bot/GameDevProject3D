shader_type canvas_item;

// Title / Splash Screen cinematic overlay
// - Keeps 3D dungeon background at very low brightness and low contrast
// - Symmetrical soft vignette
// - Top & bottom subtle letterbox gradients
// - Pure procedural: works seamlessly across all renderers.

uniform vec4 shade_color : source_color = vec4(0.035, 0.03, 0.04, 1.0);
uniform float base_darkness : hint_range(0.0, 1.0) = 0.60;
uniform float edge_darkness : hint_range(0.0, 1.0) = 0.50;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.65;
uniform float vignette_radius : hint_range(0.1, 1.0) = 0.35;
uniform float vignette_softness : hint_range(0.05, 1.0) = 0.50;

void fragment() {
	vec2 uv = UV;

	// Symmetrical top and bottom edge gradient
	float top = 1.0 - smoothstep(0.0, 0.30, uv.y);
	float bottom = smoothstep(0.70, 1.0, uv.y);
	float edge_fade = edge_darkness * (top + bottom);

	// Aspect-corrected radial vignette
	vec2 d = uv - vec2(0.5);
	d.x *= 1.35;
	float vig = vignette_strength * smoothstep(vignette_radius, vignette_radius + vignette_softness, length(d));

	// Combine into final alpha
	float a = clamp(base_darkness + edge_fade * (1.0 - base_darkness) + vig * (1.0 - base_darkness), 0.0, 0.98);
	COLOR = vec4(shade_color.rgb, a);
}
