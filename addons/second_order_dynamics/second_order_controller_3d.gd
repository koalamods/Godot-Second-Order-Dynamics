@tool
extends Node3D
class_name SecondOrderController3D

enum UpdateMode {
	PROCESS,
	PHYSICS_PROCESS
}

enum TransformChannel {
	POSITION,
	ROTATION,
	SCALE,
	POSITION_AND_ROTATION,
	POSITION_ROTATION_AND_SCALE
}

enum PositionApplyMode {
	DIRECT_TRANSFORM,
	CHARACTER_BODY_MOVE_AND_SLIDE
}

## Second order dynamics settings for position.
@export var position_dynamics: SecondOrderDynamics3D:
	set(value):
		position_dynamics = value
		_initialize_dynamics()

## Second order dynamics settings for rotation.
@export var rotation_dynamics: SecondOrderDynamics3D:
	set(value):
		rotation_dynamics = value
		_initialize_dynamics()

## Second order dynamics settings for scale.
@export var scale_dynamics: SecondOrderDynamics3D:
	set(value):
		scale_dynamics = value
		_initialize_dynamics()

## Source Node3D whose transform is used as the input target.
@export var input_node: Node3D:
	set(value):
		input_node = value
		_initialize_dynamics()

## NodePath to the Node3D that should be modified.
## Resolved relative to this controller.
@export var target_node_path: NodePath

## Selects which transform values are driven by the second order system.
@export var transform_channel: TransformChannel = TransformChannel.POSITION:
	set(value):
		transform_channel = value
		_initialize_dynamics()

## Controls how position is applied to the target.
## DIRECT_TRANSFORM writes global_position directly.
## CHARACTER_BODY_MOVE_AND_SLIDE uses CharacterBody3D.velocity and move_and_slide().
@export var position_apply_mode: PositionApplyMode = PositionApplyMode.DIRECT_TRANSFORM

## Selects where the second order system is updated.
@export var update_mode: UpdateMode = UpdateMode.PROCESS:
	set(value):
		update_mode = value
		_update_process_mode()

## Allows the controller to update while editing the scene.
@export var update_in_editor: bool = false:
	set(value):
		update_in_editor = value
		_update_process_mode()

## Resets the controlled target transform and internal second order state.
@export_tool_button("Reset Second Order Target Transform")
var reset_second_order_target_button: Callable:
	get:
		return Callable(self, "reset_target_transform")

var _last_input_rotation: Vector3
var _has_last_input_rotation: bool = false

func _enter_tree() -> void:
	_update_process_mode()


func _ready() -> void:
	_initialize_dynamics()
	_update_process_mode()


func _process(delta: float) -> void:
	if update_mode == UpdateMode.PROCESS:
		_update_dynamics(delta)


func _physics_process(delta: float) -> void:
	if update_mode == UpdateMode.PHYSICS_PROCESS:
		_update_dynamics(delta)


func _update_dynamics(delta: float) -> void:
	if delta <= 0.0:
		return

	if Engine.is_editor_hint() and not update_in_editor:
		return

	if input_node == null:
		return

	var target := get_node_or_null(target_node_path) as Node3D

	if target == null:
		return

	if _uses_position():
		_update_position(delta, target)

	if _uses_rotation():
		_update_rotation(delta, target)

	if _uses_scale():
		_update_scale(delta, target)


func _update_position(delta: float, target: Node3D) -> void:
	if position_dynamics == null:
		return

	var desired_position := position_dynamics.update(
		delta,
		input_node.global_position
	)

	if not _is_finite_vector3(desired_position):
		return

	match position_apply_mode:
		PositionApplyMode.DIRECT_TRANSFORM:
			target.global_position = desired_position

		PositionApplyMode.CHARACTER_BODY_MOVE_AND_SLIDE:
			var body := target as CharacterBody3D

			if body == null:
				push_warning("Position Apply Mode is CHARACTER_BODY_MOVE_AND_SLIDE, but target is not a CharacterBody3D.")
				return

			var delta_position := desired_position - body.global_position
			body.velocity = delta_position / delta
			body.move_and_slide()


func _update_rotation(delta: float, target: Node3D) -> void:
	if rotation_dynamics == null:
		return

	var input_rotation := input_node.rotation

	if not _has_last_input_rotation:
		_last_input_rotation = input_rotation
		_has_last_input_rotation = true

	var unwrapped_rotation := _unwrap_rotation(_last_input_rotation, input_rotation)
	_last_input_rotation = unwrapped_rotation

	var desired_rotation := rotation_dynamics.update(
		delta,
		unwrapped_rotation
	)

	if not _is_finite_vector3(desired_rotation):
		return

	target.rotation = desired_rotation


func _update_scale(delta: float, target: Node3D) -> void:
	if scale_dynamics == null:
		return

	var desired_scale := scale_dynamics.update(
		delta,
		input_node.scale
	)

	if not _is_finite_vector3(desired_scale):
		return

	target.scale = desired_scale


func reset_target_transform() -> void:
	var target := get_node_or_null(target_node_path) as Node3D

	if target == null:
		return

	var reset_position := Vector3.ZERO
	var reset_rotation := Vector3.ZERO
	var reset_scale := Vector3.ONE

	if input_node != null:
		if _is_finite_vector3(input_node.global_position):
			reset_position = input_node.global_position

		if _is_finite_vector3(input_node.rotation):
			reset_rotation = input_node.rotation

		if _is_finite_vector3(input_node.scale):
			reset_scale = input_node.scale

	target.global_position = reset_position
	target.rotation = reset_rotation
	target.scale = reset_scale

	if position_dynamics != null:
		position_dynamics.reset(reset_position)

	if rotation_dynamics != null:
		_last_input_rotation = reset_rotation
		_has_last_input_rotation = true
		rotation_dynamics.reset(reset_rotation)

	if scale_dynamics != null:
		scale_dynamics.reset(reset_scale)

	if Engine.is_editor_hint():
		target.notify_property_list_changed()
		notify_property_list_changed()


func _initialize_dynamics() -> void:
	if input_node == null:
		return

	if position_dynamics != null and _is_finite_vector3(input_node.global_position):
		position_dynamics.initialize(input_node.global_position)

	if rotation_dynamics != null and _is_finite_vector3(input_node.rotation):
		_last_input_rotation = input_node.rotation
		_has_last_input_rotation = true
		rotation_dynamics.initialize(input_node.rotation)

	if scale_dynamics != null and _is_finite_vector3(input_node.scale):
		scale_dynamics.initialize(input_node.scale)


func _uses_position() -> bool:
	return (
		transform_channel == TransformChannel.POSITION
		or transform_channel == TransformChannel.POSITION_AND_ROTATION
		or transform_channel == TransformChannel.POSITION_ROTATION_AND_SCALE
	)


func _uses_rotation() -> bool:
	return (
		transform_channel == TransformChannel.ROTATION
		or transform_channel == TransformChannel.POSITION_AND_ROTATION
		or transform_channel == TransformChannel.POSITION_ROTATION_AND_SCALE
	)


func _uses_scale() -> bool:
	return (
		transform_channel == TransformChannel.SCALE
		or transform_channel == TransformChannel.POSITION_ROTATION_AND_SCALE
	)


func _update_process_mode() -> void:
	var should_run := true

	if Engine.is_editor_hint() and not update_in_editor:
		should_run = false

	set_process(should_run and update_mode == UpdateMode.PROCESS)
	set_physics_process(should_run and update_mode == UpdateMode.PHYSICS_PROCESS)


func _is_finite_vector3(value: Vector3) -> bool:
	return (
		is_finite(value.x)
		and is_finite(value.y)
		and is_finite(value.z)
	)

func _unwrap_angle(previous: float, current: float) -> float:
	var difference := wrapf(current - previous, -PI, PI)
	return previous + difference


func _unwrap_rotation(previous: Vector3, current: Vector3) -> Vector3:
	return Vector3(
		_unwrap_angle(previous.x, current.x),
		_unwrap_angle(previous.y, current.y),
		_unwrap_angle(previous.z, current.z)
	)
