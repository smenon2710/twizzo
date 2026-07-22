class_name Launcher
extends Node2D

signal shoot_requested(direction: Vector2)

const MAX_DEVIATION_DEG: float = 75.0

const BASE_RADIUS: float = 48.0
const ORB_RADIUS: float = 34.0

var aim_dir: Vector2 = Vector2.UP
var enabled: bool = true
var loaded_color: Color = Color.WHITE

func _process(_delta: float) -> void:
	var target := get_global_mouse_position()
	var dir := target - global_position
	if dir.length() > 1.0:
		aim_dir = _clamp_upward(dir.normalized())
	$AimLine.points = PackedVector2Array([Vector2.ZERO, aim_dir * 350.0])
	queue_redraw()

func _clamp_upward(dir: Vector2) -> Vector2:
	var up := Vector2.UP
	var angle := up.angle_to(dir)
	var max_dev := deg_to_rad(MAX_DEVIATION_DEG)
	angle = clamp(angle, -max_dev, max_dev)
	return up.rotated(angle)

func _draw() -> void:
	draw_circle(Vector2.ZERO, BASE_RADIUS, Color(0.15, 0.15, 0.2))
	draw_circle(Vector2.ZERO, ORB_RADIUS, loaded_color)
	draw_arc(Vector2.ZERO, ORB_RADIUS - 2.5, 0.0, TAU, 32, Color(0.08, 0.08, 0.1), 5.0)
	draw_circle(Vector2(-ORB_RADIUS * 0.32, -ORB_RADIUS * 0.32), ORB_RADIUS * 0.16, Color(1, 1, 1, 0.85))
	var pointer_base := aim_dir * (ORB_RADIUS + 4.0)
	var tip := aim_dir * (ORB_RADIUS + 24.0)
	var left := pointer_base + aim_dir.rotated(deg_to_rad(150)) * 12.0
	var right := pointer_base + aim_dir.rotated(deg_to_rad(-150)) * 12.0
	draw_colored_polygon(PackedVector2Array([tip, left, right]), Color(0.95, 0.95, 1.0))

func _unhandled_input(event: InputEvent) -> void:
	if not enabled:
		return
	var pressed: bool = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
		or (event is InputEventScreenTouch and event.pressed)
	if pressed:
		shoot_requested.emit(aim_dir)
