@tool
extends Resource
class_name SecondOrderDynamics3D

## Natural frequency of the second order system.
## Higher values make the output follow the input faster.
## Typical range: 0.5 to 8.0.
@export_range(0.001, 20.0, 0.001, "or_greater")
var f: float = 1.0:
	set(value):
		f = max(value, 0.0001)
		_recalculate_constants()
		emit_changed()

## Damping ratio of the system.
## Lower values create more overshoot and springiness.
## A value around 1.0 is close to critically damped.
## Values above 1.0 are more sluggish but stable.
@export_range(0.0, 5.0, 0.001, "or_greater")
var z: float = 1.0:
	set(value):
		z = value
		_recalculate_constants()
		emit_changed()

## Initial response amount.
## Controls how strongly the system reacts to input velocity.
## Positive values can create anticipation or overshoot.
## Negative values can create a delayed or eased-in response.
@export_range(-5.0, 5.0, 0.001, "or_less", "or_greater")
var r: float = 0.0:
	set(value):
		r = value
		_recalculate_constants()
		emit_changed()

var xp: Vector3
var y: Vector3
var yd: Vector3

var _w: float
var _z: float
var _d: float
var k1: float
var k2: float
var k3: float

var _initialized: bool = false


func _init() -> void:
	resource_local_to_scene = true
	_recalculate_constants()


func initialize(initial_position: Vector3) -> void:
	_recalculate_constants()

	xp = initial_position
	y = initial_position
	yd = Vector3.ZERO
	_initialized = true


func reset(position: Vector3) -> void:
	initialize(position)


func update(delta: float, x: Vector3, xd: Variant = null) -> Vector3:
	if delta <= 0.0:
		return y

	if not _is_finite_vector3(x):
		return y

	if not _initialized:
		initialize(x)

	var input_velocity: Vector3

	if xd == null:
		input_velocity = (x - xp) / delta
		xp = x
	else:
		input_velocity = xd

	if not _is_finite_vector3(input_velocity):
		input_velocity = Vector3.ZERO

	var k1_stable: float
	var k2_stable: float

	if _w * delta < _z:
		k1_stable = k1
		k2_stable = max(
			k2,
			max(
				delta * delta * 0.5 + delta * k1 * 0.5,
				delta * k1
			)
		)
	else:
		var t1 := exp(-_z * _w * delta)

		var alpha: float
		if _z <= 1.0:
			alpha = 2.0 * t1 * cos(delta * _d)
		else:
			alpha = 2.0 * t1 * _cosh(delta * _d)

		var beta := t1 * t1
		var t2 := delta / (1.0 + beta - alpha)

		k1_stable = (1.0 - beta) * t2
		k2_stable = delta * t2

	if abs(k2_stable) < 0.000001:
		return y

	y = y + delta * yd
	yd = yd + delta * (x + k3 * input_velocity - y - k1_stable * yd) / k2_stable

	if not _is_finite_vector3(y) or not _is_finite_vector3(yd):
		initialize(x)
		return x

	return y


func get_preview_points(
	duration: float = 2.0,
	steps: int = 120
) -> PackedVector2Array:
	var points := PackedVector2Array()

	var preview_xp := 0.0
	var preview_y := 0.0
	var preview_yd := 0.0

	var safe_steps: int = max(steps, 2)
	var delta := duration / float(safe_steps - 1)

	points.append(Vector2(0.0, preview_y))

	for i in range(1, safe_steps):
		var time := float(i) * delta

		var x := 1.0
		var xd := (x - preview_xp) / delta
		preview_xp = x

		var k1_stable: float
		var k2_stable: float

		if _w * delta < _z:
			k1_stable = k1
			k2_stable = max(
				k2,
				max(
					delta * delta * 0.5 + delta * k1 * 0.5,
					delta * k1
				)
			)
		else:
			var t1 := exp(-_z * _w * delta)

			var alpha: float
			if _z <= 1.0:
				alpha = 2.0 * t1 * cos(delta * _d)
			else:
				alpha = 2.0 * t1 * _cosh(delta * _d)

			var beta := t1 * t1
			var t2 := delta / (1.0 + beta - alpha)

			k1_stable = (1.0 - beta) * t2
			k2_stable = delta * t2

		if abs(k2_stable) < 0.000001:
			points.append(Vector2(time, preview_y))
			continue

		preview_y = preview_y + delta * preview_yd
		preview_yd = preview_yd + delta * (
			x + k3 * xd - preview_y - k1_stable * preview_yd
		) / k2_stable

		if not is_finite(preview_y) or not is_finite(preview_yd):
			preview_y = x
			preview_yd = 0.0

		points.append(Vector2(time, preview_y))

	return points


func _recalculate_constants() -> void:
	var safe_f: float = max(f, 0.0001)

	_w = 2.0 * PI * safe_f
	_z = z
	_d = _w * sqrt(abs(z * z - 1.0))

	k1 = z / (PI * safe_f)
	k2 = 1.0 / (_w * _w)
	k3 = r * z / _w


func _cosh(value: float) -> float:
	return (exp(value) + exp(-value)) * 0.5


func _is_finite_vector3(value: Vector3) -> bool:
	return (
		is_finite(value.x)
		and is_finite(value.y)
		and is_finite(value.z)
	)
