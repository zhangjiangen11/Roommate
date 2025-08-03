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
const GIZMO_PLUGIN_SCRIPT := preload("./gizmos/gizmo_plugin.gd")
const CONTROL_SCENES: Array[PackedScene] = [
	preload("./controls/root_actions/root_actions.tscn"),
	preload("./controls/blocks_area_actions/blocks_area_actions.tscn"),
]

var _controls: Array[Control] = []
var _gizmo_plugin: GIZMO_PLUGIN_SCRIPT


func _init() -> void:
	_gizmo_plugin = GIZMO_PLUGIN_SCRIPT.new(self)


func _enter_tree() -> void:
	get_editor_interface().get_selection().selection_changed.connect(_update_controls_visibility)
	SETTINGS.init_settings(get_editor_interface().get_editor_settings())
	add_node_3d_gizmo_plugin(_gizmo_plugin)
	for scene in CONTROL_SCENES:
		var control := scene.instantiate() as Control
		control.set(&"plugin", self)
		add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, control)
		_controls.append(control)
	_update_controls_visibility()


func _exit_tree() -> void:
	get_editor_interface().get_selection().selection_changed.disconnect(_update_controls_visibility)
	for control in _controls:
		remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, control)
		control.free()
	_controls.clear()
	remove_node_3d_gizmo_plugin(_gizmo_plugin)


func _disable_plugin() -> void:
	if SETTINGS.get_bool(&"stid_clear_settings_when_plugin_disabled"):
		SETTINGS.clear(get_editor_interface().get_editor_settings())


func generate_roots(roots: Array[RoommateRoot]) -> void:
	if roots.is_empty():
		return
	var undo_redo := get_undo_redo()
	undo_redo.create_action("ROOMMATE: Generate Root(s)")
	for root in roots:
		root.generate()
	undo_redo.commit_action()


func snap_roots_areas(roots: Array[RoommateRoot]) -> void:
	if roots.is_empty():
		return
	var undo_redo := get_undo_redo()
	undo_redo.create_action("ROOMMATE: Snap Root's Areas To Blocks")
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


func snap_areas(areas: Array[RoommateBlocksArea]) -> void:
	if areas.is_empty():
		return
	var undo_redo := get_undo_redo()
	undo_redo.create_action("ROOMMATE: Snap Area(s) To Blocks")
	for area in areas:
		var related_root := area.find_root()
		if not related_root:
			continue
		undo_redo.add_undo_property(area, &"transform", area.transform)
		undo_redo.add_undo_property(area, &"size", area.size)
		area.snap_to_range(related_root.global_transform, related_root.block_size)
		undo_redo.add_do_property(area, &"transform", area.transform)
		undo_redo.add_do_property(area, &"size", area.size)
	undo_redo.commit_action()


func _remove_root_scenes(root: RoommateRoot) -> void:
	var undo_redo := get_undo_redo()
	for scene in root.get_owned_scenes():
		#undo_redo.add_undo_method(scene.get_parent(), &"add_child", scene)
		undo_redo.add_undo_reference(scene)
		undo_redo.add_do_method(scene.get_parent(), &"remove_child", scene)


func _update_controls_visibility() -> void:
	var nodes := get_editor_interface().get_selection().get_selected_nodes()
	for control in _controls:
		var callable := Callable(control, &"visibility_predicate")
		control.visible = callable.is_valid() and callable.call(nodes) as bool


func _match_shortcut(setting_id: StringName, event: InputEvent) -> bool:
	var editor_settings := get_editor_interface().get_editor_settings()
	var shortcut := SETTINGS.get_shortcut(setting_id, editor_settings)
	return shortcut and shortcut.matches_event(event)
