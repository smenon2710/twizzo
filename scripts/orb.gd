class_name Orb
extends Node2D

const RADIUS: float = 45.0

var color: Color = Color.WHITE

func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, color)
	draw_arc(Vector2.ZERO, RADIUS - 1.5, 0.0, TAU, 32, color.darkened(0.4), 3.0)
	draw_circle(Vector2(-RADIUS * 0.3, -RADIUS * 0.3), RADIUS * 0.22, color.lightened(0.55))

func set_orb_color(c: Color) -> void:
	color = c
	queue_redraw()
