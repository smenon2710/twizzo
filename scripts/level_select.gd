extends Node2D

@onready var level_nodes: Array[LevelNode] = [$LevelNode1, $LevelNode2, $LevelNode3, $LevelNode4, $LevelNode5]
@onready var exit_button: TextButton = $ExitButton

func _ready() -> void:
	for i in range(level_nodes.size()):
		var stars: int = GameState.best_stars.get(i, 0)
		var locked: bool = not GameState.is_level_unlocked(i)
		level_nodes[i].setup(i, stars, locked)
		level_nodes[i].selected.connect(_on_level_selected)
	exit_button.set_text("EXIT")
	exit_button.pressed.connect(_on_exit_pressed)

func _on_level_selected(index: int) -> void:
	if not GameState.is_level_unlocked(index):
		return
	GameState.level_index = index
	get_tree().change_scene_to_file("res://main.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
