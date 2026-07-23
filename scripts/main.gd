extends Node2D

const SHOT_SPEED: float = 900.0

# Chance any given shot is a rainbow (wildcard) orb instead of a normal
# color — a flat-probability variable-ratio schedule, deliberately hidden
# from the player (Section 3.2 of the game plan).
const WILDCARD_CHANCE: float = 0.12

# Each entry: initial rows, distinct colors in play, total row-descents,
# seconds between descents, and seconds to clear the board once descents end
# (0 = no countdown / no fail state, just clear it whenever). Each level
# introduces at most one new difficulty dimension at a time: L1 is a quick
# no-stakes tutorial, L2 adds volume, L3 adds the countdown (same colors as
# L2), L4 adds ONLY a 4th color (identical rows/shifts/interval/time-budget
# to L3, so the harder-matching color count is isolated and gentle rather
# than compounding with more content and less time at once — L4 used to
# also bump rows/shifts/interval simultaneously, which was 4 difficulty
# changes at once disguised as "just one more color" and felt like a
# sudden spike), L5 is the finale and ramps rows/shifts/interval/colors/
# timer together — the one place a bigger jump is intentional.
# star3/star2: clear-time thresholds (seconds, from level start) for 3/2
# stars; slower than star2 still earns 1 star. First-pass estimates —
# expect to retune once there's real playtest data on clear times.
#
# For levels with a real endgame countdown (3-5), star2 is deliberately
# set to equal shifts*interval (the exact moment drops stop) — that keeps
# the "1-star floor" and "the real countdown begins" as the SAME moment,
# so the story is a single clean line: beat star3 for 3★, beat star2
# (=drops stopping) for 2★, and once you're in that final real-countdown
# window you get exactly `endgame` more seconds to finish for 1★ or lose.
# Before this, star2 fell partway through an already-running countdown on
# every level, which had no clean answer to "how long do I actually have."
const LEVELS: Array[Dictionary] = [
	{"rows": 2, "colors": 3, "shifts": 2, "interval": 7.0, "endgame": 0.0, "star3": 50.0, "star2": 80.0},
	{"rows": 4, "colors": 3, "shifts": 5, "interval": 8.0, "endgame": 0.0, "star3": 80.0, "star2": 125.0},
	{"rows": 4, "colors": 3, "shifts": 5, "interval": 7.0, "endgame": 40.0, "star3": 20.0, "star2": 35.0},
	{"rows": 4, "colors": 4, "shifts": 5, "interval": 7.0, "endgame": 50.0, "star3": 26.0, "star2": 42.0},
	{"rows": 4, "colors": 5, "shifts": 6, "interval": 6.5, "endgame": 50.0, "star3": 24.0, "star2": 39.0},
]

enum State { PLAYING, WON, LOST }

@onready var playfield: PlayField = $PlayField
@onready var launcher: Launcher = $Launcher
@onready var level_label: Label = $UI/StatusPanel/LevelLabel
@onready var status_label: Label = $UI/StatusPanel/StatusLabel
@onready var star_display: StarDisplay = $UI/StarDisplay
@onready var star_gauge: StarGauge = $UI/StarGauge
@onready var pie_gauge: PieGauge = $UI/PieGauge
@onready var map_button: TextButton = $UI/MapButton
@onready var shift_timer: Timer = $ShiftTimer
@onready var lose_line: Line2D = $LoseLine
@onready var camera: Camera2D = $Camera2D

var state: State = State.PLAYING
var shifts_remaining: int = 0
var flying_orb: Orb = null
var flying_velocity: Vector2 = Vector2.ZERO
var next_color: Color
var next_is_wildcard: bool = false
var in_endgame: bool = false
var endgame_time_left: float = 0.0
var endgame_seconds: float = 20.0
var level_start_msec: int = 0

func _ready() -> void:
	var level: Dictionary = LEVELS[GameState.level_index]
	playfield.configure(level["colors"])
	playfield.fill_initial(level["rows"])
	shifts_remaining = level["shifts"]
	endgame_seconds = level["endgame"]
	_pick_next_shot()
	launcher.shoot_requested.connect(_on_shoot_requested)
	shift_timer.wait_time = level["interval"]
	shift_timer.timeout.connect(_on_shift_timer_timeout)
	shift_timer.start()
	_position_lose_line()
	level_label.text = "LEVEL %d" % (GameState.level_index + 1)
	map_button.set_text("< MAP")
	map_button.pressed.connect(_on_map_pressed)
	star_display.set_stars(0)
	level_start_msec = Time.get_ticks_msec()
	_update_hud()

func _update_hud() -> void:
	if shifts_remaining > 0:
		status_label.text = "Drops left: %d" % shifts_remaining
	elif in_endgame:
		var seconds_left: int = ceili(endgame_time_left)
		status_label.text = "Clear it! %ds left" % seconds_left
	else:
		status_label.text = "Clear the board to win!"

func _process(delta: float) -> void:
	if state != State.PLAYING:
		return
	_update_star_gauge()
	if not in_endgame:
		return
	endgame_time_left -= delta
	if endgame_time_left <= 0.0:
		endgame_time_left = 0.0
		_update_hud()
		_end_game(false, "Ran out of time")
		return
	_update_hud()

func _update_star_gauge() -> void:
	var level: Dictionary = LEVELS[GameState.level_index]
	var elapsed: float = (Time.get_ticks_msec() - level_start_msec) / 1000.0
	star_display.set_stars(_compute_stars(level, elapsed))
	if in_endgame:
		# real fail-state countdown is running — swap to the pie gauge
		# entirely (a different shape, not just a recolored bar) so it
		# reads unmistakably as a different kind of clock than star-tier
		# progress: this one ending means losing, not a worse rating
		star_gauge.hide_gauge()
		var danger_fill: float = endgame_time_left / endgame_seconds if endgame_seconds > 0.0 else 0.0
		pie_gauge.set_fill(danger_fill)
		return
	var star3: float = level["star3"]
	var star2: float = level["star2"]
	var fill: float
	if elapsed <= star3:
		fill = 1.0 - (elapsed / star3)
	elif elapsed <= star2:
		fill = 1.0 - ((elapsed - star3) / (star2 - star3))
	else:
		fill = 0.0
	star_gauge.set_fill(fill)

func _pick_next_shot() -> void:
	next_is_wildcard = randf() < WILDCARD_CHANCE
	if next_is_wildcard:
		launcher.loaded_is_wildcard = true
	else:
		next_color = playfield.random_color_in_play()
		launcher.loaded_is_wildcard = false
		launcher.loaded_color = next_color

func _position_lose_line() -> void:
	var y: float = PlayField.TOP_MARGIN + PlayField.LOSE_ROW * PlayField.ROW_HEIGHT
	lose_line.points = PackedVector2Array([Vector2(0, y), Vector2(playfield.board_width, y)])

# Juice: a simple decaying camera-offset jitter — bigger matches (or a
# loss) shake harder. Camera offset only (not position), so it never
# drifts the launcher's aim math.
func _shake_camera(strength: float, duration: float = 0.3) -> void:
	if camera == null:
		return
	var tw := create_tween()
	var steps: int = 6
	for i in range(steps):
		var decay: float = 1.0 - float(i) / float(steps)
		var jitter := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * strength * decay
		tw.tween_property(camera, "offset", jitter, duration / steps).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(camera, "offset", Vector2.ZERO, duration / steps)

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
		_shake_camera(clampf(3.0 + float(group.size()) * 1.4, 3.0, 20.0), 0.28)
		var floating := playfield.find_floating()
		if not floating.is_empty():
			playfield.remove_orbs(floating, true)
	_check_end_conditions()

func _check_end_conditions() -> void:
	if playfield.has_lost():
		_end_game(false, "Cluster reached the bottom")
		return
	if shifts_remaining <= 0 and playfield.cells.is_empty():
		_end_game(true)

func _on_shift_timer_timeout() -> void:
	if shifts_remaining <= 0 or state != State.PLAYING:
		return
	shifts_remaining -= 1
	playfield.shift_down()
	if shifts_remaining <= 0:
		shift_timer.stop()
		if endgame_seconds > 0.0:
			in_endgame = true
			endgame_time_left = endgame_seconds
	_update_hud()
	_check_end_conditions()

func _on_shoot_requested(direction: Vector2) -> void:
	if state != State.PLAYING or flying_orb != null:
		return
	SFX.play_shot()
	flying_orb = PlayField.ORB_SCENE.instantiate()
	if next_is_wildcard:
		flying_orb.set_wildcard()
	else:
		flying_orb.set_orb_color(next_color)
	flying_orb.position = launcher.position + direction * 70.0
	add_child(flying_orb)
	flying_velocity = direction * SHOT_SPEED
	_pick_next_shot()

func _end_game(won: bool, lose_reason: String = "") -> void:
	state = State.WON if won else State.LOST
	launcher.enabled = false
	shift_timer.stop()
	in_endgame = false
	star_gauge.hide_gauge()
	pie_gauge.hide_gauge()
	if won:
		SFX.play_win()
		var completed_index := GameState.level_index
		var completed_level: Dictionary = LEVELS[completed_index]
		var elapsed: float = (Time.get_ticks_msec() - level_start_msec) / 1000.0
		var stars := _compute_stars(completed_level, elapsed)
		GameState.best_stars[completed_index] = max(GameState.best_stars.get(completed_index, 0), stars)
		GameState.save_progress()
		star_display.set_stars(stars)
		var next_index := (completed_index + 1) % LEVELS.size()
		if next_index == 0:
			level_label.text = "ALL CLEAR!"
			status_label.text = "Tap to start over"
		else:
			status_label.text = "Level clear! Tap for Level %d" % (next_index + 1)
		GameState.level_index = next_index
	else:
		SFX.play_lose()
		_shake_camera(16.0, 0.35)
		star_display.set_stars(0)
		status_label.text = "%s. Tap to retry" % lose_reason

func _compute_stars(level: Dictionary, elapsed: float) -> int:
	if elapsed <= level["star3"]:
		return 3
	if elapsed <= level["star2"]:
		return 2
	return 1

func _on_map_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if state == State.PLAYING:
		return
	var pressed: bool = (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed)
	if not pressed:
		return
	get_tree().reload_current_scene()
