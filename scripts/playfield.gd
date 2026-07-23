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
	Color(0.95, 0.18, 0.22), # red
	Color(0.15, 0.55, 0.98), # blue
	Color(0.20, 0.82, 0.35), # green
	Color(1.00, 0.82, 0.10), # yellow
	Color(0.68, 0.25, 0.92), # purple
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
	var candidates: Array[Color] = []
	for orb in cells.values():
		if not orb.is_wildcard:
			candidates.append(orb.color)
	if candidates.is_empty():
		return random_color()
	return candidates[randi() % candidates.size()]

func add_orb_at(coord: Vector2i, color: Color, wildcard: bool = false) -> Orb:
	var orb: Orb = ORB_SCENE.instantiate()
	if wildcard:
		orb.set_wildcard()
	else:
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
			if not cells.has(n) or visited.has(n):
				continue
			var neighbor: Orb = cells[n]
			# a resting wildcard always bridges into whatever color group
			# touches it — keeps it from ever getting permanently stuck
			if neighbor.is_wildcard or neighbor.color.is_equal_approx(target_color):
				visited[n] = true
				stack.append(n)
				group.append(n)
	return group

# Called only for the orb that was JUST placed, when it's the wildcard
# itself. A universal wild: pops EVERY distinct-color neighbor group that
# would reach 3+ once the wildcard joins it, not just the single largest —
# closer to genre convention, and it can chain a satisfying multi-color
# combo instead of arbitrarily picking one color over another.
func flood_fill_from_wildcard(start: Vector2i) -> Array[Vector2i]:
	var combined: Dictionary = {}
	var tried_colors := {}
	for n in get_neighbors(start):
		if not cells.has(n):
			continue
		var neighbor: Orb = cells[n]
		if neighbor.is_wildcard:
			continue
		var key := neighbor.color.to_html()
		if tried_colors.has(key):
			continue
		tried_colors[key] = true
		var group := flood_fill_color(n)
		# flood_fill_color's own wildcard-bridging can re-discover `start`
		# from the other direction — exclude it so a truly lone neighbor
		# doesn't look like a qualifying pair just because of that bridge
		group.erase(start)
		if group.size() >= 2:
			for c in group:
				combined[c] = true
	if combined.is_empty():
		return []
	combined[start] = true
	var result: Array[Vector2i] = []
	for c in combined.keys():
		result.append(c)
	return result

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
	if coords.is_empty():
		return
	if with_fall:
		SFX.play_fall()
	else:
		SFX.play_pop(coords.size())
	for c in coords:
		if not cells.has(c):
			continue
		var orb: Orb = cells[c]
		cells.erase(c)
		var tw := create_tween()
		if with_fall:
			# orbs left floating after a match tumble away — ease-in mimics
			# gravity picking up speed rather than a flat linear drop.
			# The fade is delayed so the orb stays visible while it's
			# clearly dropping, then fades quickly near the end — fading
			# in sync with the slow start of an ease-in position tween
			# made it look like it was hovering in place, not falling.
			tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tw.tween_property(orb, "position:y", orb.position.y + 500.0, 0.5)
			tw.parallel().tween_property(orb, "modulate:a", 0.0, 0.2).set_delay(0.3)
		else:
			# actual match pop: a squash-stretch — a quick overshoot bump
			# up in size, then a bouncy shrink to nothing — instead of the
			# old flat linear scale-to-zero
			_spawn_particle_burst(orb.position, orb.color if not orb.is_wildcard else Color(1, 1, 1))
			tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(orb, "scale", Vector2(1.3, 1.3), 0.06)
			tw.tween_property(orb, "scale", Vector2.ZERO, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw.tween_callback(orb.queue_free)

func shift_down() -> void:
	var old_cells := cells.duplicate()
	cells.clear()
	for c in old_cells.keys():
		var new_c := Vector2i(c.x, c.y + 1)
		var orb: Orb = old_cells[c]
		cells[new_c] = orb
		# every shift flips every orb's row parity (odd rows sit half a
		# cell to the right in this offset hex grid), so a full position
		# tween drags each orb sideways too — alternating rows visibly
		# zigzag apart in opposite directions mid-slide, which read as
		# pieces disconnecting/floating before snapping back together.
		# Snap x instantly and only animate the vertical drop instead.
		var target := grid_to_local(new_c)
		orb.position.x = target.x
		var tw := create_tween()
		tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(orb, "position:y", target.y, 0.25)
	for col in range(0, max_col_for_row(0) + 1):
		add_orb_at(Vector2i(col, 0), random_color())

# ---- juice: particle burst ----

static var _particle_texture: ImageTexture

static func _get_particle_texture() -> ImageTexture:
	if _particle_texture == null:
		var img: Image = Image.create(12, 12, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var center := Vector2(5.5, 5.5)
		for y in range(12):
			for x in range(12):
				if Vector2(x, y).distance_to(center) <= 5.5:
					img.set_pixel(x, y, Color(1, 1, 1, 1))
		_particle_texture = ImageTexture.create_from_image(img)
	return _particle_texture

func _spawn_particle_burst(pos: Vector2, color: Color) -> void:
	var particles := CPUParticles2D.new()
	particles.position = pos
	particles.texture = _get_particle_texture()
	particles.emitting = false
	particles.one_shot = true
	particles.amount = 10
	particles.lifetime = 0.4
	particles.explosiveness = 1.0
	particles.direction = Vector2.UP
	particles.spread = 180.0
	particles.gravity = Vector2(0, 420.0)
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 210.0
	particles.scale_amount_min = 0.35
	particles.scale_amount_max = 0.65
	particles.color = color
	add_child(particles)
	particles.finished.connect(particles.queue_free)
	particles.emitting = true

func has_lost() -> bool:
	for c in cells.keys():
		if c.y >= LOSE_ROW:
			return true
	return false
