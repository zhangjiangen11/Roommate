# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateStyle
extends Resource

@export var apply_order := 0

var _current_rulesets: Array[RoommateRuleset] = []
var _current_ruleset: RoommateRuleset
var _current_setter: RoommatePartsSetter


func build() -> void:
	_current_rulesets.clear()
	_current_ruleset = null
	_current_setter = null
	create_ruleset()
	_build_rulesets()


func apply(source_blocks: Dictionary) -> void:
	for ruleset in _current_rulesets:
		ruleset.apply(source_blocks)


func create_ruleset() -> void:
	_current_ruleset = RoommateRuleset.new()
	_current_rulesets.append(_current_ruleset)


func select_all_blocks() -> void:
	if not _has_current_ruleset():
		return
	_current_ruleset.block_selectors.append(_selector_all_blocks)


func select_edge_blocks(selected_edge: Vector3i) -> void:
	if not _has_current_ruleset():
		return
	var binded := _selector_edge_blocks.bind(selected_edge)
	_current_ruleset.block_selectors.append(binded)


func select_parts(slot_ids: Array[StringName]) -> void:
	if not _has_current_ruleset():
		return
	_current_setter = RoommatePartsSetter.new()
	_current_setter.selected_slot_ids = slot_ids
	_current_ruleset.parts_setters.append(_current_setter)


func select_all_parts() -> void:
	select_parts([
		&"sid_center",
		&"sid_up",
		&"sid_down",
		&"sid_left",
		&"sid_right",
		&"sid_forward",
		&"sid_back",
	])


func select_all_walls() -> void:
	select_parts([
		&"sid_left",
		&"sid_right",
		&"sid_forward",
		&"sid_back",
	])


func set_offset(offset: Vector3) -> void:
	if not _has_current_setter():
		return
	_current_setter.new_values[&"offset"] = offset


func set_mesh(mesh: Mesh) -> void:
	if not _has_current_setter():
		return
	_current_setter.new_values[&"mesh"] = mesh


func _selector_all_blocks(source_blocks: Dictionary) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	result.assign(source_blocks.keys())
	return result


func _selector_edge_blocks(source_blocks: Dictionary, selected_edge: Vector3i) -> Array[Vector3i]:
	var result: Array[Vector3i] = []
	var biggest_values := Vector3i(-Vector3.INF)
	var smallest_values := Vector3i(Vector3.INF) - Vector3i.ONE
	for block_position in source_blocks:
		biggest_values = Vector3i(maxi(block_position.x, biggest_values.x),
				maxi(block_position.y, biggest_values.y), maxi(block_position.z, biggest_values.z))
		smallest_values = Vector3i(mini(block_position.x, smallest_values.x),
				mini(block_position.y, smallest_values.y), mini(block_position.z, smallest_values.z))
	
	var required_x = null
	var required_y = null
	var required_z = null
	
	if selected_edge.x > 0:
		required_x = biggest_values.x
	elif selected_edge.x < 0:
		required_x = smallest_values.x
	
	if selected_edge.y > 0:
		required_y = biggest_values.y
	elif selected_edge.y < 0:
		required_y = smallest_values.y
	
	if selected_edge.z > 0:
		required_z = biggest_values.z
	elif selected_edge.z < 0:
		required_z = smallest_values.z
	
	for block_position in source_blocks:
		if required_x != null and required_x != block_position.x:
			continue
		if required_y != null and required_y != block_position.y:
			continue
		if required_z != null and required_z != block_position.z:
			continue
		result.append(block_position)
	return result


func _has_current_ruleset() -> bool:
	if not _current_ruleset:
		push_error("Ruleset is not created.")
		return false
	return true


func _has_current_setter() -> bool:
	if not _has_current_ruleset():
		return false
	if not _current_setter:
		push_error("Setter is not created.")
		return false
	return true


func _build_rulesets() -> void: # virtual function
	pass
