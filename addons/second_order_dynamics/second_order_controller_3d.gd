@tool
extends Node3D
class_name SecondOrderController3D

enum UpdateMode {
	PROCESS,
	PHYSICS_PROCESS
}

## Second order dynamics settings used by this controller.
## Create or assign a SecondOrderDynamics3D resource here.
## The resource stores f, z, r, target_node_path, and the internal simulation state.
@export var dynamics: SecondOrderDynamics3D:
	set(value):
		dynamics = value
		_initialize_dynamics()

## Source Node3D whose global_position is used as the input target.
## The selected target node from the dynamics resource will move toward this node's position.
@export var input_node: Node3D:
	set(value):
		input_node = value
		_initialize_dynamics()

## Selects where the second order system is updated.
## PROCESS updates every rendered frame.
## PHYSICS_PROCESS updates at the fixed physics timestep.
@export var update_mode: UpdateMode = UpdateMode.PROCESS:
	set(value):
		update_mode = value
		_update_process_mode()

## Allows the controller to update while editing the scene.
## Keep this disabled unless you specifically want live editor previews,
## because tool scripts can modify scene transforms in the editor.
@export var update_in_editor: bool = false:
	set(value):
		update_in_editor = value
		_update_process_mode()

## Resets the controlled target transform and internal second order state.
## Useful if unstable parameters caused the target position to become infinite or invalid.
@export_tool_button("Reset Second Order Target Transform")
var reset_second_order_target_button: Callable:
	get:
		return Callable(self, "reset_target_transform")


func _enter_tree() -> void:
	_update_process_mode()


func _ready() -> void:
	_initialize_dynamics()
	_update_process_mode()


func _process(delta: float) -> void:
	if update_mode != UpdateMode.PROCESS:
		return

	_update_dynamics(delta)


func _physics_process(delta: float) -> void:
	if update_mode != UpdateMode.PHYSICS_PROCESS:
		return

	_update_dynamics(delta)


func _update_dynamics(delta: float) -> void:
	if delta <= 0.0:
		return

	if Engine.is_editor_hint() and not update_in_editor:
		return

	if dynamics == null:
		return

	if input_node == null:
		return

	dynamics.apply_to_target(
		self,
		delta,
		input_node.global_position
	)


func reset_target_transform() -> void:
	if dynamics == null:
		return

	var target := get_node_or_null(dynamics.target_node_path) as Node3D

	if target == null:
		return

	var reset_position := Vector3.ZERO

	if input_node != null and _is_finite_vector3(input_node.global_position):
		reset_position = input_node.global_position

	target.global_position = reset_position
	target.rotation = Vector3.ZERO
	target.scale = Vector3.ONE

	dynamics.reset(reset_position)

	if Engine.is_editor_hint():
		target.notify_property_list_changed()
		notify_property_list_changed()


func _initialize_dynamics() -> void:
	if dynamics == null:
		return

	if input_node == null:
		return

	if not _is_finite_vector3(input_node.global_position):
		return

	dynamics.initialize(input_node.global_position)


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
