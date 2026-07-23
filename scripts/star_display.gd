class_name StarDisplay
extends Node2D

const STAR_RADIUS: float = 14.0
const INNER_RATIO: float = 0.42
const SPACING: float = 34.0

const FILLED_COLOR: Color = Color(1.0, 0.82, 0.15)
const EMPTY_COLOR: Color = Color(0.35, 0.35, 0.42)
const OUTLINE_COLOR: Color = Color(0.08, 0.08, 0.1)

var stars: int = 0

func _draw() -> void:
	for i in range(3):
		var center := Vector2((i - 1) * SPACING, 0)
		_draw_star(center, i < stars)

func _draw_star(center: Vector2, filled: bool) -> void:
	var points := PackedVector2Array()
	for i in range(10):
		var angle := deg_to_rad(-90 + i * 36)
		var r := STAR_RADIUS if i % 2 == 0 else STAR_RADIUS * INNER_RATIO
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(points, FILLED_COLOR if filled else EMPTY_COLOR)
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, OUTLINE_COLOR, 3.0, true)

func set_stars(n: int) -> void:
	stars = n
	visible = n > 0
	queue_redraw()
