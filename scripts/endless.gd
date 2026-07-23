extends Node2D

const SHOT_SPEED: float = 900.0
const WILDCARD_CHANCE: float = 0.12

const INITIAL_ROWS: int = 3
const COLORS_IN_PLAY: int = 5
const INITIAL_INTERVAL: float = 6.0
const MIN_INTERVAL: float = 1.8
const INTERVAL_DECAY_PER_SHIFT: float = 0.15

@onready var playfield: PlayField = $PlayField
@onready var launcher: Launcher = $Launcher
@onready var level_label: Label = $UI/StatusPanel/LevelLabel
@onready var status_label: Label = $UI/StatusPanel/StatusLabel
@onready var map_button: TextButton = $UI/MapButton
@onready var shift_timer: Timer = $ShiftTimer
@onready var lose_line: Line2D = $LoseLine

var alive: bool = true
var flying_orb: Orb = null
var flying_velocity: Vector2 = Vector2.ZERO
var next_color: Color
var next_is_wildcard: bool = false
var current_interval: float = INITIAL_INTERVAL
var start_msec: int = 0
var best_score: float = 0.0

func _ready() -> void:
	playfield.configure(COLORS_IN_PLAY)
	playfield.fill_initial(INITIAL_ROWS)
	_pick_next_shot()
	launcher.shoot_requested.connect(_on_shoot_requested)
	shift_timer.wait_time = current_interval
	shift_timer.timeout.connect(_on_shift_timer_timeout)
	shift_timer.start()
	_position_lose_line()
	level_label.text = "ENDLESS"
	map_button.set_text("< MAP")
	map_button.pressed.connect(_on_map_pressed)
	best_score = GameState.endless_best_score
	start_msec = Time.get_ticks_msec()
	_update_hud()

func _position_lose_line() -> void:
	var y: float = PlayField.TOP_MARGIN + PlayField.LOSE_ROW * PlayField.ROW_HEIGHT
	lose_line.points = PackedVector2Array([Vector2(0, y), Vector2(playfield.board_width, y)])

func _update_hud() -> void:
	var elapsed: float = (Time.get_ticks_msec() - start_msec) / 1000.0
	status_label.text = "Survived %ds — best %ds" % [int(elapsed), int(best_score)]

func _process(_delta: float) -> void:
	if not alive:
		return
	_update_hud()

func _physics_process(delta: float) -> void:
	if flying_orb == null:
		return
	flying_orb.position += flying_velocity * delta
	var pos: Vector2 = flying_orb.position
	if pos.x <= PlayField.RADIUS:
		flying_orb.position.x = PlayField.RADIUS
		flying_velocity.x = abs(flying_velocity.x)
	elif pos.x >= playfield.board_width - PlayField.RADIUS:
		flying_orb.position.x = playfield.board_width - PlayField.RADIUS
		flying_velocity.x = -abs(flying_velocity.x)
	if playfield.check_hit(flying_orb.position):
		_settle_flying_orb()

func _settle_flying_orb() -> void:
	var coord := playfield.find_snap_cell(flying_orb.position)
	if coord.x < 0:
		return
	var color: Color = flying_orb.color
	var was_wildcard: bool = flying_orb.is_wildcard
	flying_orb.queue_free()
	flying_orb = null
	playfield.add_orb_at(coord, color, was_wildcard)
	var group: Array[Vector2i] = playfield.flood_fill_from_wildcard(coord) if was_wildcard else playfield.flood_fill_color(coord)
	if group.size() >= 3:
		playfield.remove_orbs(group)
		var floating := playfield.find_floating()
		if not floating.is_empty():
			playfield.remove_orbs(floating, true)
	if playfield.has_lost():
		_end_run()

func _on_shift_timer_timeout() -> void:
	if not alive:
		return
	playfield.shift_down()
	current_interval = max(MIN_INTERVAL, current_interval - INTERVAL_DECAY_PER_SHIFT)
	shift_timer.wait_time = current_interval
	if playfield.has_lost():
		_end_run()

func _pick_next_shot() -> void:
	next_is_wildcard = randf() < WILDCARD_CHANCE
	if next_is_wildcard:
		launcher.loaded_is_wildcard = true
	else:
		next_color = playfield.random_color_in_play()
		launcher.loaded_is_wildcard = false
		launcher.loaded_color = next_color

func _on_shoot_requested(direction: Vector2) -> void:
	if not alive or flying_orb != null:
		return
	flying_orb = PlayField.ORB_SCENE.instantiate()
	if next_is_wildcard:
		flying_orb.set_wildcard()
	else:
		flying_orb.set_orb_color(next_color)
	flying_orb.position = launcher.position + direction * 70.0
	add_child(flying_orb)
	flying_velocity = direction * SHOT_SPEED
	_pick_next_shot()

func _end_run() -> void:
	alive = false
	launcher.enabled = false
	shift_timer.stop()
	var elapsed: float = (Time.get_ticks_msec() - start_msec) / 1000.0
	var is_new_best: bool = elapsed > GameState.endless_best_score
	if is_new_best:
		GameState.endless_best_score = elapsed
		GameState.save_progress()
	var suffix: String = " — NEW BEST!" if is_new_best else ""
	status_label.text = "Survived %ds%s Tap to retry" % [int(elapsed), suffix]

func _on_map_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if alive:
		return
	var pressed: bool = (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed)
	if not pressed:
		return
	get_tree().reload_current_scene()
