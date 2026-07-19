@tool
extends EditorPlugin

var inspector_plugin: EditorInspectorPlugin


func _enter_tree() -> void:
	inspector_plugin = preload("res://addons/second_order_dynamics/second_order_inspector_plugin.gd").new()
	add_inspector_plugin(inspector_plugin)


func _exit_tree() -> void:
	if inspector_plugin != null:
		remove_inspector_plugin(inspector_plugin)
		inspector_plugin = null
