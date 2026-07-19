@tool
extends EditorInspectorPlugin

const SecondOrderPreviewControlScript := preload("res://addons/second_order_dynamics/second_order_preview_control.gd")



func _can_handle(object: Object) -> bool:
	return object is SecondOrderDynamics3D


func _parse_begin(object: Object) -> void:
	var preview := SecondOrderPreviewControlScript.new()
	preview.set_dynamics(object as SecondOrderDynamics3D)

	add_custom_control(preview)
