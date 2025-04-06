# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateRuleset
extends Resource

@export var block_selectors: Array[RoommateBlocksSelector]
@export var parts_setters: Array[RoommatePartsSetter]


func apply(source_blocks: RoommateBlocksArea.Blocks) -> void:
	var selected_blocks := RoommateBlocksArea.Blocks.new()
	for selector in block_selectors:
		if not selector:
			continue
		var selector_result := selector.select(source_blocks)
		selected_blocks.merge(selector_result)
	
	var source_parts: Array[RoommatePart] = []
	for block in selected_blocks.get_all():
		source_parts.append_array(block.parts.values())
	
	for setter in parts_setters:
		if not setter:
			continue
		setter.set_all(source_parts)


func get_materials() -> Array[Material]:
	var result: Array[Material] = []
	for setter in parts_setters:
		if not setter:
			continue
		var setter_materials := setter.get_materials()
		for material in setter_materials:
			if material and not material in result:
				result.append(material)
	return result


func select_all_parts() -> RoommatePart:
	var part := RoommatePart.new()
	var setter := RoommateAllSpacePartsSetter.new()
	setter.setter = part
	return part


func select_all_walls() -> RoommatePart:
	var part := RoommatePart.new()
	var setter := RoommateSpacePartsSetter.new()
	setter.wall_forward_setter = part
	setter.wall_back_setter = part
	setter.wall_left_setter = part
	setter.wall_right_setter = part
	parts_setters.append(setter)
	return part;
