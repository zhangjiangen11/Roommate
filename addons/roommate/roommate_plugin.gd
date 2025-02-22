@tool
extends EditorPlugin

const ROOT_ACTIONS_SCENE := preload("res://addons/roommate/controls/roommate_root_actions/roommate_root_actions.tscn")

var _root_actions: RoommateRootActions
var box_edit_gizmo_plugin := BoxEditGizmoPlugin.new()

func _enter_tree() -> void:
	EditorInterface.get_selection().selection_changed.connect(_update_controls_visibility)
	
	add_custom_type(_name_of(RoommateRoot), "MeshInstance3D", RoommateRoot, preload("res://icon.svg"))
	add_custom_type(_name_of(RoommateSpace), _name_of(RoommateAreaBase), RoommateSpace, preload("res://icon.svg"))
	add_custom_type(_name_of(RoommateOutOfBounds), _name_of(RoommateAreaBase), RoommateOutOfBounds, preload("res://icon.svg"))
	add_node_3d_gizmo_plugin(box_edit_gizmo_plugin)
	
	_root_actions = ROOT_ACTIONS_SCENE.instantiate() as RoommateRootActions
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _root_actions)
	_update_controls_visibility()


func _exit_tree() -> void:
	EditorInterface.get_selection().selection_changed.disconnect(_update_controls_visibility)
	
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _root_actions)
	_root_actions.free()
	_root_actions = null
	
	remove_node_3d_gizmo_plugin(box_edit_gizmo_plugin)
	remove_custom_type(_name_of(RoommateRoot))
	remove_custom_type(_name_of(RoommateSpace))
	remove_custom_type(_name_of(RoommateOutOfBounds))


func _update_controls_visibility() -> void:
	if not _root_actions:
		return
	var nodes := EditorInterface.get_selection().get_selected_nodes()
	var is_extends := func(node: Node) -> bool:
		return node is RoommateRoot
	_root_actions.visible = nodes.any(is_extends)


func _name_of(script: Script) -> StringName:
	return script.get_global_name()
