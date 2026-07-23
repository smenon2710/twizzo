class_name StarGauge
extends Node2D

const WIDTH: float = 220.0
const HEIGHT: float = 18.0
const TRACK_COLOR: Color = Color(0.2, 0.2, 0.24)
const OUTLINE_COLOR: Color = Color(0.08, 0.08, 0.1)
const FULL_COLOR: Color = Color(0.35, 0.82, 0.4)
const EMPTY_COLOR: Color = Color(0.92, 0.25, 0.22)

var fill: float = 1.0

func _draw() -> void:
	var half_w := WIDTH * 0.5
	var half_h := HEIGHT * 0.5
	draw_rect(Rect2(-half_w, -half_h, WIDTH, HEIGHT), TRACK_COLOR, true)
	var fill_w: float = WIDTH * clampf(fill, 0.0, 1.0)
	if fill_w > 0.5:
		draw_rect(Rect2(-half_w, -half_h, fill_w, HEIGHT), _fill_color(), true)
	draw_rect(Rect2(-half_w, -half_h, WIDTH, HEIGHT), OUTLINE_COLOR, false, 3.0)

func _fill_color() -> Color:
	# drains from green toward red as the current star tier runs out —
	# a moving cue reads as more pressure than a static icon changing state
	return FULL_COLOR.lerp(EMPTY_COLOR, 1.0 - clampf(fill, 0.0, 1.0))

func set_fill(f: float) -> void:
	fill = f
	visible = true
	queue_redraw()

func hide_gauge() -> void:
	visible = false
