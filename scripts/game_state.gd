extends Node

const SAVE_PATH: String = "user://save.json"

var level_index: int = 0

# level index (int) -> best star rating ever earned for that level (1-3).
# Persisted to disk; loaded on startup, saved whenever a level is cleared.
var best_stars: Dictionary = {}

func _ready() -> void:
	load_progress()

func is_level_unlocked(index: int) -> bool:
	if index == 0:
		return true
	return best_stars.has(index - 1)

func save_progress() -> void:
	var data := {"best_stars": best_stars}
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
