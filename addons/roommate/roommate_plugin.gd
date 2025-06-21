# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends EditorPlugin

const ROOT_ACTIONS_SCENE := preload("./controls/roommate_root_actions/roommate_root_actions.tscn")

var _root_actions: Control
var _gizmo_plugin := preload("./gizmos/gizmo_plugin.gd").new()


func _enter_tree() -> void:
	get_editor_interface().get_selection().selection_changed.connect(_update_controls_visibility)
	add_node_3d_gizmo_plugin(_gizmo_plugin)
	_root_actions = ROOT_ACTIONS_SCENE.instantiate() as Control
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _root_actions)
	_update_controls_visibility()


func _exit_tree() -> void:
	get_editor_interface().get_selection().selection_changed.disconnect(_update_controls_visibility)
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _root_actions)
	_root_actions.free()
	_root_actions = null
	remove_node_3d_gizmo_plugin(_gizmo_plugin)


func _update_controls_visibility() -> void:
	if not _root_actions:
		return
	var nodes := get_editor_interface().get_selection().get_selected_nodes()
	var is_extends := func(node: Node) -> bool:
		return node is RoommateRoot
	_root_actions.visible = nodes.any(is_extends)
