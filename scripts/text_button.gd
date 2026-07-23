class_name TextButton
extends Node2D

signal pressed

@export var width: float = 120.0
@export var height: float = 44.0

@onready var label: Label = $Label

func set_text(t: String) -> void:
	label.text = t

func _draw() -> void:
	var rect := Rect2(-width / 2.0, -height / 2.0, width, height)
	draw_rect(rect, Color(0.22, 0.24, 0.32), true)
	draw_rect(rect, Color(0.08, 0.08, 0.1), false, 4.0)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	var is_pressed: bool = (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) \
		or (event is InputEventScreenTouch and event.pressed)
	if not is_pressed:
		return
	var pos: Vector2 = (event as InputEventMouseButton).position if event is InputEventMouseButton else (event as InputEventScreenTouch).position
	var rect := Rect2(global_position - Vector2(width, height) / 2.0, Vector2(width, height))
	if rect.has_point(pos):
		SFX.play_tap()
		pressed.emit()
