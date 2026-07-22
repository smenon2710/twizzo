class_name Orb
extends Node2D

const RADIUS: float = 45.0

var color: Color = Color.WHITE

func _draw() -> void:
	# flat saturated fill — no gradient/shading, reads instantly at a glance
	draw_circle(Vector2.ZERO, RADIUS, color)

	# thick clean cartoon-sticker outline
	draw_arc(Vector2.ZERO, RADIUS - 3.0, 0.0, TAU, 40, Color(0.08, 0.08, 0.1), 6.0)

	# single small clean gloss dot — friendly, not a heavy 3D specular
	draw_circle(Vector2(-RADIUS * 0.32, -RADIUS * 0.32), RADIUS * 0.16, Color(1, 1, 1, 0.85))

func set_orb_color(c: Color) -> void:
	color = c
	queue_redraw()
