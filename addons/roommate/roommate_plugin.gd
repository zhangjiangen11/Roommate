# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends EditorPlugin

const SETTINGS := preload("./plugin_settings.gd")
const ROOT_ACTIONS_SCENE := preload("./controls/roommate_root_actions/roommate_root_actions.tscn")
const ROOT_ACTIONS_SCRIPT := preload("./controls/roommate_root_actions/roommate_root_actions.gd")

var _root_actions: Control
var _gizmo_plugin := preload("./gizmos/gizmo_plugin.gd").new(self)


func _enter_tree() -> void:
	get_editor_interface().get_selection().selection_changed.connect(_update_controls_visibility)
	add_node_3d_gizmo_plugin(_gizmo_plugin)
	_root_actions = ROOT_ACTIONS_SCENE.instantiate() as ROOT_ACTIONS_SCRIPT
	_root_actions.plugin = self
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _root_actions)
	_update_controls_visibility()
	SETTINGS.init_settings(get_editor_interface().get_editor_settings())


func _exit_tree() -> void:
	get_editor_interface().get_selection().selection_changed.disconnect(_update_controls_visibility)
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, _root_actions)
	_root_actions.free()
	_root_actions = null
	remove_node_3d_gizmo_plugin(_gizmo_plugin)


func _shortcut_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): 
		return
	if _match_shortcut(&"stid_generate_root_nodes_shortcut", event):
		generate_roots(_get_root_nodes_by_selected_children())


func generate_roots(roots: Array[RoommateRoot]) -> void:
	if roots.is_empty():
		return
	for root in roots:
		root.generate()


func clear_roots_scenes(roots: Array[RoommateRoot]) -> void:
	if roots.is_empty():
		return
	for root in roots:
		root.clear_scenes()


func snap_roots_areas(roots: Array[RoommateRoot]) -> void:
	if roots.is_empty():
		return
	for root in roots:
		root.snap_areas()


func _update_controls_visibility() -> void:
	if not _root_actions:
		return
	var nodes := get_editor_interface().get_selection().get_selected_nodes()
	var is_extends := func(node: Node) -> bool:
		return node is RoommateRoot
	_root_actions.visible = nodes.any(is_extends)


func _match_shortcut(setting_id: StringName, event: InputEvent) -> bool:
	var editor_settings := get_editor_interface().get_editor_settings()
	var generate_shortcut := SETTINGS.get_shortcut(setting_id, editor_settings)
	return generate_shortcut and generate_shortcut.is_match(event)


func _get_root_nodes_by_selected_children() -> Array[RoommateRoot]:
	var selected_nodes := get_editor_interface().get_selection().get_selected_nodes()
	var scene_root := get_editor_interface().get_edited_scene_root()
	var roots: Array[RoommateRoot] = []
	roots.assign(scene_root.find_children("*", RoommateRoot.get_class_name()))
	var filter_by_child := func(root: RoommateRoot) -> bool:
		for node in selected_nodes:
			if root == node or root.is_ancestor_of(node):
				return true
		return false
	return roots.filter(filter_by_child)
