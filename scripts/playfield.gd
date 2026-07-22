class_name PlayField
extends Node2D

const ORB_SCENE: PackedScene = preload("res://scenes/orb.tscn")

const RADIUS: float = 45.0
const DIAMETER: float = RADIUS * 2.0
const ROW_HEIGHT: float = DIAMETER * 0.866
const COLS_EVEN: int = 8
const COLS_ODD: int = 7
const TOP_MARGIN: float = 80.0
const LOSE_ROW: int = 11

const COLORS: Array[Color] = [
	Color(0.90, 0.25, 0.30), # red
	Color(0.25, 0.55, 0.95), # blue
	Color(0.30, 0.80, 0.40), # green
	Color(0.95, 0.80, 0.20), # yellow
	Color(0.65, 0.35, 0.85), # purple
]

var board_width: float = COLS_EVEN * DIAMETER
var active_color_count: int = COLORS.size()

# Vector2i(col, row) -> Orb
var cells: Dictionary = {}

func _ready() -> void:
	randomize()

func configure(color_count: int) -> void:
	active_color_count = clampi(color_count, 1, COLORS.size())

func grid_to_local(coord: Vector2i) -> Vector2:
	var x_offset := RADIUS if coord.y % 2 == 1 else 0.0
	var x := x_offset + coord.x * DIAMETER + RADIUS
	var y := TOP_MARGIN + coord.y * ROW_HEIGHT + RADIUS
	return Vector2(x, y)

func max_col_for_row(row: int) -> int:
	return (COLS_ODD - 1) if row % 2 == 1 else (COLS_EVEN - 1)

func get_neighbors(coord: Vector2i) -> Array[Vector2i]:
	var diffs: Array
	if coord.y % 2 == 0:
		diffs = [[1, 0], [0, -1], [-1, -1], [-1, 0], [-1, 1], [0, 1]]
	else:
		diffs = [[1, 0], [1, -1], [0, -1], [-1, 0], [0, 1], [1, 1]]
	var result: Array[Vector2i] = []
	for d in diffs:
		result.append(Vector2i(coord.x + d[0], coord.y + d[1]))
	return result

func has_occupied_neighbor(coord: Vector2i) -> bool:
	for n in get_neighbors(coord):
		if cells.has(n):
			return true
	return false

func random_color() -> Color:
	return COLORS[randi() % active_color_count]

func random_color_in_play() -> Color:
	if cells.is_empty():
		return random_color()
	var keys := cells.keys()
	var pick: Vector2i = keys[randi() % keys.size()]
	return cells[pick].color

func add_orb_at(coord: Vector2i, color: Color) -> Orb:
	var orb: Orb = ORB_SCENE.instantiate()
	orb.set_orb_color(color)
	orb.position = grid_to_local(coord)
	add_child(orb)
	cells[coord] = orb
	return orb

func fill_initial(rows: int) -> void:
	for row in range(rows):
		for col in range(0, max_col_for_row(row) + 1):
			add_orb_at(Vector2i(col, row), random_color())

func find_snap_cell(pos: Vector2) -> Vector2i:
	var approx_row := int(round((pos.y - TOP_MARGIN - RADIUS) / ROW_HEIGHT))
	var best_cell := Vector2i(-1, -1)
	var best_dist := INF
	for row in range(max(0, approx_row - 2), approx_row + 3):
		var max_col := max_col_for_row(row)
		for col in range(0, max_col + 1):
			var cell := Vector2i(col, row)
			if cells.has(cell):
				continue
			if row > 0 and not has_occupied_neighbor(cell):
				continue
			var d := grid_to_local(cell).distance_to(pos)
			if d < best_dist:
				best_dist = d
				best_cell = cell
	return best_cell

func check_hit(pos: Vector2) -> bool:
	if pos.y <= TOP_MARGIN + RADIUS:
		return true
	for orb in cells.values():
		if orb.position.distance_to(pos) <= DIAMETER * 0.95:
			return true
	return false

func flood_fill_color(start: Vector2i) -> Array[Vector2i]:
	if not cells.has(start):
		return []
	var target_color: Color = cells[start].color
	var visited := {start: true}
	var stack: Array[Vector2i] = [start]
	var group: Array[Vector2i] = [start]
	while not stack.is_empty():
		var cur: Vector2i = stack.pop_back()
		for n in get_neighbors(cur):
			if cells.has(n) and not visited.has(n) and cells[n].color.is_equal_approx(target_color):
				visited[n] = true
				stack.append(n)
				group.append(n)
	return group

func find_floating() -> Array[Vector2i]:
	var visited := {}
	var stack: Array[Vector2i] = []
	for c in cells.keys():
		if c.y == 0:
			visited[c] = true
			stack.append(c)
	while not stack.is_empty():
		var cur: Vector2i = stack.pop_back()
		for n in get_neighbors(cur):
			if cells.has(n) and not visited.has(n):
				visited[n] = true
				stack.append(n)
	var floating: Array[Vector2i] = []
	for c in cells.keys():
		if not visited.has(c):
			floating.append(c)
	return floating

func remove_orbs(coords: Array, with_fall: bool = false) -> void:
	for c in coords:
		if not cells.has(c):
			continue
		var orb: Orb = cells[c]
		cells.erase(c)
		var tw := create_tween()
		if with_fall:
			tw.tween_property(orb, "position:y", orb.position.y + 500.0, 0.5)
			tw.parallel().tween_property(orb, "modulate:a", 0.0, 0.5)
		else:
			tw.tween_property(orb, "scale", Vector2.ZERO, 0.15)
		tw.tween_callback(orb.queue_free)

func shift_down() -> void:
	var old_cells := cells.duplicate()
	cells.clear()
	for c in old_cells.keys():
		var new_c := Vector2i(c.x, c.y + 1)
		var orb: Orb = old_cells[c]
		cells[new_c] = orb
		var tw := create_tween()
		tw.tween_property(orb, "position", grid_to_local(new_c), 0.25)
	for col in range(0, max_col_for_row(0) + 1):
		add_orb_at(Vector2i(col, 0), random_color())

func has_lost() -> bool:
	for c in cells.keys():
		if c.y >= LOSE_ROW:
			return true
	return false
