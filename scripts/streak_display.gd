class_name StreakDisplay
extends Node2D

static var FLAME_POINTS: PackedVector2Array = PackedVector2Array([
	Vector2(0, 20), Vector2(-10, 10), Vector2(-6, -2), Vector2(-3, -14),
	Vector2(0, -20), Vector2(3, -14), Vector2(6, -2), Vector2(10, 10),
])

@onready var count_label: Label = $CountLabel

var dimmed: bool = false

func set_streak(streak_count: int, in_grace: bool) -> void:
	dimmed = in_grace
	count_label.text = str(streak_count)
	count_label.modulate = Color(1, 1, 1, 0.5) if dimmed else Color(1, 1, 1, 1)
	queue_redraw()

func _draw() -> void:
	var flame_color := Color(0.6, 0.45, 0.35) if dimmed else Color(0.95, 0.55, 0.15)
	draw_colored_polygon(FLAME_POINTS, flame_color)
	var outline := FLAME_POINTS.duplicate()
	outline.append(FLAME_POINTS[0])
	draw_polyline(outline, Color(0.08, 0.08, 0.1), 3.0, true)
