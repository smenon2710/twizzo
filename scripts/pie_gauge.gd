class_name PieGauge
extends Node2D

# Generic circular countdown indicator — deliberately has no knowledge of
# stars, levels, or Endless Mode. Anything that needs a "this is draining
# toward zero and something happens at zero" visual can reuse this as-is
# (e.g. a future Endless Mode danger cue) rather than needing its own
# one-off gauge built later.

const RADIUS: float = 26.0
const TRACK_COLOR: Color = Color(0.2, 0.2, 0.24)
const OUTLINE_COLOR: Color = Color(0.08, 0.08, 0.1)
const FILL_COLOR: Color = Color(0.95, 0.15, 0.15)

var fill: float = 1.0

func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, TRACK_COLOR)
	var f: float = clampf(fill, 0.0, 1.0)
	if f >= 0.999:
		draw_circle(Vector2.ZERO, RADIUS, FILL_COLOR)
	elif f > 0.003:
		var points := PackedVector2Array()
		points.append(Vector2.ZERO)
		var steps: int = 32
		var start_angle: float = -PI / 2.0
		var end_angle: float = start_angle + TAU * f
		for i in range(steps + 1):
			var a: float = lerp(start_angle, end_angle, float(i) / steps)
			points.append(Vector2(cos(a), sin(a)) * RADIUS)
		draw_colored_polygon(points, FILL_COLOR)
	draw_arc(Vector2.ZERO, RADIUS - 1.5, 0.0, TAU, 32, OUTLINE_COLOR, 3.0)

func set_fill(f: float) -> void:
	fill = f
	visible = true
	queue_redraw()

func hide_gauge() -> void:
	visible = false
