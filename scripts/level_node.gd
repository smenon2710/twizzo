class_name LevelNode
extends Node2D

signal selected(index: int)

const RADIUS: float = 68.0
const STAR_RADIUS: float = 11.0
const STAR_SPACING: float = 26.0

var level_index: int = 0
var stars: int = 0
var locked: bool = false

@onready var number_label: Label = $NumberLabel

func setup(index: int, star_count: int, is_locked: bool = false) -> void:
	level_index = index
	stars = star_count
	locked = is_locked
	number_label.text = str(index + 1)
	number_label.modulate = Color(1, 1, 1, 0.35) if locked else Color(1, 1, 1, 1)
	queue_redraw()

func _draw() -> void:
	var base_color := Color(0.14, 0.14, 0.18) if locked else Color(0.22, 0.24, 0.32)
	draw_circle(Vector2.ZERO, RADIUS, base_color)
	draw_arc(Vector2.ZERO, RADIUS - 3.0, 0.0, TAU, 40, Color(0.08, 0.08, 0.1), 6.0)
	var y: float = RADIUS * 0.55
	if locked:
		_draw_lock(Vector2(0, y))
	else:
		for i in range(3):
			var center := Vector2((i - 1) * STAR_SPACING, y)
			_draw_star(center, i < stars)

func _draw_lock(center: Vector2) -> void:
	var body_w: float = 26.0
	var body_h: float = 20.0
	var lock_color := Color(0.5, 0.5, 0.56)
	var body_rect := Rect2(center.x - body_w / 2.0, center.y - body_h / 2.0 + 4.0, body_w, body_h)
	draw_rect(body_rect, lock_color, true)
	draw_arc(center + Vector2(0, -body_h / 2.0), 9.0, PI, TAU, 16, lock_color, 4.0)

func _draw_star(center: Vector2, filled: bool) -> void:
	var points := PackedVector2Array()
	for i in range(10):
		var angle := deg_to_rad(-90 + i * 36)
		var r: float = STAR_RADIUS if i % 2 == 0 else STAR_RADIUS * 0.42
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(points, Color(1.0, 0.82, 0.15) if filled else Color(0.35, 0.35, 0.42))
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, Color(0.08, 0.08, 0.1), 2.0, true)

func _unhandled_input(event: InputEvent) -> void:
	if locked:
		return
	var pressed: bool = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
		or (event is InputEventScreenTouch and event.pressed)
	if not pressed:
		return
	var pos: Vector2 = (event as InputEventMouseButton).position if event is InputEventMouseButton else (event as InputEventScreenTouch).position
	if global_position.distance_to(pos) <= RADIUS:
		selected.emit(level_index)
