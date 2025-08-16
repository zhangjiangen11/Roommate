# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends RefCounted

var _ur: EditorUndoRedoManager


func _init(plugin: EditorPlugin) -> void:
	_ur = plugin.get_undo_redo()


func generate_roots(roots: Array[RoommateRoot]) -> void:
	if roots.is_empty():
		return
	_ur.create_action("ROOMMATE: Generate Root(s)")
	for root in roots:
		root.generate()
	_ur.commit_action()


func snap_roots_areas(roots: Array[RoommateRoot]) -> void:
	var root_areas_map := {}
	for root in roots:
		var areas := root.get_owned_areas()
		if not areas.is_empty():
			root_areas_map[root] = areas
	if root_areas_map.is_empty():
		return
	
	_ur.create_action("ROOMMATE: Snap Root's Area(s) To Blocks")
	for key in root_areas_map:
		var root := key as RoommateRoot
		var areas := root_areas_map[root] as Array[RoommateBlocksArea]
		for area in areas:
			_ur.add_undo_property(area, &"transform", area.transform)
			_ur.add_undo_property(area, &"size", area.size)
			area.snap_to_range(root.global_transform, root.block_size)
			_ur.add_do_property(area, &"transform", area.transform)
			_ur.add_do_property(area, &"size", area.size)
	_ur.commit_action()


func clear_roots_scenes(roots: Array[RoommateRoot]) -> void:
	var scenes: Array[Node] = []
	for root in roots:
		scenes.append_array(root.get_owned_scenes())
	if scenes.is_empty():
		return
	
	_ur.create_action("ROOMMATE: Clear Root's Scene(s)")
	for scene in scenes:
		_ur.add_undo_method(scene.get_parent(), &"add_child", scene)
		_ur.add_undo_property(scene, &"owner", scene.owner)
		_ur.add_undo_reference(scene)
		_ur.add_do_method(scene.get_parent(), &"remove_child", scene)
	_ur.commit_action()


func snap_areas(areas: Array[RoommateBlocksArea]) -> void:
	var root_area_map := {}
	for area in areas:
		var related_root := area.find_root()
		if related_root:
			root_area_map[related_root] = area
	if root_area_map.is_empty():
		return
	
	_ur.create_action("ROOMMATE: Snap Area(s) To Blocks")
	for key in root_area_map:
		var related_root := key as RoommateRoot
		var area := root_area_map[related_root] as RoommateBlocksArea
		_ur.add_undo_property(area, &"transform", area.transform)
		_ur.add_undo_property(area, &"size", area.size)
		area.snap_to_range(related_root.global_transform, related_root.block_size)
		_ur.add_do_property(area, &"transform", area.transform)
		_ur.add_do_property(area, &"size", area.size)
	_ur.commit_action()
