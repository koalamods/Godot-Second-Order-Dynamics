@tool
extends Control
class_name SecondOrderPreviewControl

var dynamics: SecondOrderDynamics3D

@export var graph_height: float = 140.0
@export var preview_duration: float = 2.0
@export var preview_steps: int = 160
@export var graph_padding: float = 8.0

var background_color := Color(0.12, 0.12, 0.12)
var grid_color := Color(0.25, 0.25, 0.25)
var target_color := Color(0.45, 0.45, 0.45)
var curve_color := Color(0.3, 0.8, 1.0)

var _min_value: float = -0.5
var _max_value: float = 1.5


func _init() -> void:
	clip_contents = true
	custom_minimum_size = Vector2(240.0, graph_height)


func _get_minimum_size() -> Vector2:
	return Vector2(240.0, graph_height)


func set_dynamics(value: SecondOrderDynamics3D) -> void:
	if dynamics != null and dynamics.changed.is_connected(_on_dynamics_changed):
		dynamics.changed.disconnect(_on_dynamics_changed)

	dynamics = value

	if dynamics != null and not dynamics.changed.is_connected(_on_dynamics_changed):
		dynamics.changed.connect(_on_dynamics_changed)

	queue_redraw()


func _on_dynamics_changed() -> void:
	queue_redraw()


func _draw() -> void:
	var full_rect := Rect2(Vector2.ZERO, size)

	# Debug background. If you see this, the control is visible.
	draw_rect(full_rect, background_color, true)

	if dynamics == null:
		return

	var graph_rect := full_rect.grow(-graph_padding)

	if graph_rect.size.x <= 0.0 or graph_rect.size.y <= 0.0:
		return

	var points := dynamics.get_preview_points(preview_duration, preview_steps)

	if points.size() < 2:
		return

	_update_value_range(points)

	_draw_grid(graph_rect)
	_draw_target_line(graph_rect)
	_draw_curve(graph_rect, points)


func _update_value_range(points: PackedVector2Array) -> void:
	var min_y := 0.0
	var max_y := 1.0

	for point in points:
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)

	min_y = min(min_y, 1.0)
	max_y = max(max_y, 1.0)

	var value_range := max_y - min_y

	if value_range < 0.001:
		value_range = 1.0

	var padding := value_range * 0.15

	_min_value = min_y - padding
	_max_value = max_y + padding


func _draw_grid(rect: Rect2) -> void:
	var vertical_lines := 6
	var horizontal_lines := 4

	for i in range(vertical_lines + 1):
		var x := rect.position.x + rect.size.x * float(i) / float(vertical_lines)
		draw_line(
			Vector2(x, rect.position.y),
			Vector2(x, rect.position.y + rect.size.y),
			grid_color,
			1.0
		)

	for i in range(horizontal_lines + 1):
		var y := rect.position.y + rect.size.y * float(i) / float(horizontal_lines)
		draw_line(
			Vector2(rect.position.x, y),
			Vector2(rect.position.x + rect.size.x, y),
			grid_color,
			1.0
		)


func _draw_target_line(rect: Rect2) -> void:
	var target_y := _value_to_screen_y(1.0, rect)

	draw_line(
		Vector2(rect.position.x, target_y),
		Vector2(rect.position.x + rect.size.x, target_y),
		target_color,
		1.0
	)


func _draw_curve(rect: Rect2, points: PackedVector2Array) -> void:
	var max_time := max(points[points.size() - 1].x, 0.001)

	for i in range(points.size() - 1):
		var a := points[i]
		var b := points[i + 1]

		var screen_a := Vector2(
			rect.position.x + rect.size.x * a.x / max_time,
			_value_to_screen_y(a.y, rect)
		)

		var screen_b := Vector2(
			rect.position.x + rect.size.x * b.x / max_time,
			_value_to_screen_y(b.y, rect)
		)

		draw_line(screen_a, screen_b, curve_color, 2.0)


func _value_to_screen_y(value: float, rect: Rect2) -> float:
	var normalized := inverse_lerp(_min_value, _max_value, value)
	var y := rect.position.y + rect.size.y * (1.0 - normalized)

	return clamp(y, rect.position.y, rect.position.y + rect.size.y)
