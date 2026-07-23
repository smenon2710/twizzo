extends Node

const SAVE_PATH: String = "user://save.json"

var level_index: int = 0

# level index (int) -> best star rating ever earned for that level (1-3).
# Persisted to disk; loaded on startup, saved whenever a level is cleared.
var best_stars: Dictionary = {}

# Daily streak: consecutive calendar days played. Missing exactly one day
# doesn't reset it (a 1-day "grace") — missing two or more does.
var streak_count: int = 0
var last_play_date: String = ""
var streak_in_grace: bool = false

# Endless mode: unlocked once every base level has been cleared at least
# once. Best survival time (seconds) persists like everything else.
const ENDLESS_UNLOCK_LEVEL: int = 4
var endless_best_score: float = 0.0

func _ready() -> void:
	load_progress()
	_update_streak()

func is_level_unlocked(index: int) -> bool:
	if index == 0:
		return true
	return best_stars.has(index - 1)

func is_endless_unlocked() -> bool:
	return best_stars.has(ENDLESS_UNLOCK_LEVEL)

func _update_streak() -> void:
	var today: String = Time.get_date_string_from_system()
	if last_play_date == today:
		pass
	elif last_play_date == "":
		streak_count = 1
		streak_in_grace = false
	else:
		var last_unix: float = Time.get_unix_time_from_datetime_string(last_play_date)
		var today_unix: float = Time.get_unix_time_from_datetime_string(today)
		var days_diff: int = int(round((today_unix - last_unix) / 86400.0))
		if days_diff == 1:
			streak_count += 1
			streak_in_grace = false
		elif days_diff == 2:
			# missed exactly one day — the streak survives, but flagged
			# as having used its grace (shown dimmed rather than reset)
			streak_in_grace = true
		else:
			streak_count = 1
			streak_in_grace = false
	last_play_date = today
	save_progress()

func save_progress() -> void:
	var data := {
		"best_stars": best_stars,
		"streak_count": streak_count,
		"last_play_date": last_play_date,
		"streak_in_grace": streak_in_grace,
		"endless_best_score": endless_best_score,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data))
	file.close()

func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var raw_stars: Dictionary = parsed.get("best_stars", {})
	best_stars.clear()
	for key in raw_stars.keys():
		# JSON object keys are always strings; convert back to int level indices
		best_stars[int(key)] = int(raw_stars[key])
	streak_count = int(parsed.get("streak_count", 0))
	last_play_date = String(parsed.get("last_play_date", ""))
	streak_in_grace = bool(parsed.get("streak_in_grace", false))
	endless_best_score = float(parsed.get("endless_best_score", 0.0))
