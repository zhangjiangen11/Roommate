# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateRuleset
extends RefCounted

var block_selectors: Array[Callable] = []
var parts_setters: Array[RoommatePartsSetter] = []


func apply(source_blocks: Dictionary) -> void:
	if block_selectors.size() == 0:
		push_warning("Ruleset doesnt have block selectors")
	if parts_setters.size() == 0:
		push_warning("Ruleset doesnt have parts setters")
	
	var selected_blocks := {}
	for selector in block_selectors:
		if not selector.is_valid():
			push_warning("Block selector %s is not valid" % [selector.get_method()])
			continue
		var selected_block_positions := selector.call(source_blocks) as Array[Vector3i]
		for selected_block_position in selected_block_positions:
			selected_blocks[selected_block_position] = source_blocks[selected_block_position]
	
	for setter in parts_setters:
		if not setter:
			push_warning("Setter is null")
			continue
		for block_position in selected_blocks:
			var block := selected_blocks[block_position] as RoommateBlock
			setter.apply(block.slots)


func get_materials() -> Array[Material]:
	var result: Array[Material] = []
	for setter in parts_setters:
		if not setter:
			push_warning("Setter is null")
			continue
		var setter_material := setter.new_values.get(&"material") as Material
		if setter_material and not setter_material in result:
			result.append(setter_material)
	return result
