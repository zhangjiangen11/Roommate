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
	if SETTINGS.get_bool(&"stid_clear_settings_when_plugin_disabled"):
		SETTINGS.clear(get_editor_interface().get_editor_settings())


func _shortcut_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo(): 
		return
	if _match_shortcut(&"stid_generate_root_nodes_shortcut", event):
		generate_roots(_get_root_nodes_by_selected_children())
	elif _match_shortcut(&"stid_snap_roots_areas_shortcut", event):
		snap_roots_areas(_get_root_nodes_by_selected_children())
	elif _match_shortcut(&"stid_clear_scenes_shortcut", event):
		clear_roots_scenes(_get_root_nodes_by_selected_children())


func generate_roots(roots: Array[RoommateRoot]) -> void:
	if roots.is_empty():
		return
	for root in roots:
		root.generate()


func snap_roots_areas(roots: Array[RoommateRoot]) -> void:
	if roots.is_empty():
		return
	var undo_redo := get_undo_redo()
	undo_redo.create_action("ROOMMATE: Snap Areas To Blocks Range")
	for root in roots:
		var areas := root.get_owned_areas()
		for area in areas:
			undo_redo.add_undo_property(area, &"transform", area.transform)
			undo_redo.add_undo_property(area, &"size", area.size)
			area.snap_to_range(root.global_transform, root.block_size)
			undo_redo.add_do_property(area, &"transform", area.transform)
			undo_redo.add_do_property(area, &"size", area.size)
	undo_redo.commit_action()


func clear_roots_scenes(roots: Array[RoommateRoot]) -> void:
	if roots.is_empty():
		return
	var undo_redo := get_undo_redo()
	undo_redo.create_action("ROOMMATE: Clear Root's Scenes")
	for root in roots:
		_remove_root_scenes(root)
	undo_redo.commit_action()


func _remove_root_scenes(root: RoommateRoot) -> void:
	var undo_redo := get_undo_redo()
	for scene in root.get_owned_scenes():
		#undo_redo.add_undo_method(scene.get_parent(), &"add_child", scene)
		undo_redo.add_undo_reference(scene)
		undo_redo.add_do_method(scene.get_parent(), &"remove_child", scene)


func _update_controls_visibility() -> void:
	if not _root_actions:
		return
	var nodes := get_editor_interface().get_selection().get_selected_nodes()
	var is_extends := func(node: Node) -> bool:
		return node is RoommateRoot
	_root_actions.visible = nodes.any(is_extends)


func _match_shortcut(setting_id: StringName, event: InputEvent) -> bool:
	var editor_settings := get_editor_interface().get_editor_settings()
	var shortcut := SETTINGS.get_shortcut(setting_id, editor_settings)
	return shortcut and shortcut.matches_event(event)


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
