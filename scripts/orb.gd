class_name Orb
extends Node2D

const RADIUS: float = 45.0

const WILDCARD_COLORS: Array[Color] = [
	Color(0.95, 0.18, 0.22),
	Color(1.00, 0.82, 0.10),
	Color(0.20, 0.82, 0.35),
	Color(0.15, 0.55, 0.98),
	Color(0.68, 0.25, 0.92),
]

var color: Color = Color.WHITE
var is_wildcard: bool = false

func _draw() -> void:
	if is_wildcard:
		draw_wildcard_fill(self, RADIUS)
	else:
		# flat saturated fill — no gradient/shading, reads instantly at a glance
		draw_circle(Vector2.ZERO, RADIUS, color)

	# thick clean cartoon-sticker outline
	draw_arc(Vector2.ZERO, RADIUS - 3.0, 0.0, TAU, 40, Color(0.08, 0.08, 0.1), 6.0)

	# single small clean gloss dot — friendly, not a heavy 3D specular
	draw_circle(Vector2(-RADIUS * 0.32, -RADIUS * 0.32), RADIUS * 0.16, Color(1, 1, 1, 0.85))

# Shared so Launcher can render the same wildcard look for the loaded-shot preview.
static func draw_wildcard_fill(ci: CanvasItem, radius: float) -> void:
	var n: int = WILDCARD_COLORS.size()
	var steps: int = 6
	for i in range(n):
		var a0: float = TAU * i / n
		var a1: float = TAU * (i + 1) / n
		var points: PackedVector2Array = PackedVector2Array()
		points.append(Vector2.ZERO)
		for s in range(steps + 1):
			var a: float = lerp(a0, a1, float(s) / steps)
			points.append(Vector2(cos(a), sin(a)) * radius)
		ci.draw_colored_polygon(points, WILDCARD_COLORS[i])

func set_orb_color(c: Color) -> void:
	color = c
	is_wildcard = false
	queue_redraw()

func set_wildcard() -> void:
	is_wildcard = true
	color = Color.WHITE
	queue_redraw()
