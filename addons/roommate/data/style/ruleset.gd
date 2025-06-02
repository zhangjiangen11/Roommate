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

var _blocks_selectors: Array[RoommateBlocksSelector] = []
var _parts_setters: Array[RoommatePartsSetter] = []


func apply(source_blocks: Dictionary) -> void:
	if _blocks_selectors.size() == 0:
		push_warning("Ruleset doesnt have blocks selectors")
	if _parts_setters.size() == 0:
		push_warning("Ruleset doesnt have parts setters")
	for block_position in source_blocks:
		var include := false
		var block := source_blocks[block_position] as RoommateBlock
		for blocks_selector in _blocks_selectors:
			if blocks_selector.check_selection.call(block, source_blocks):
				include = blocks_selector.mode == RoommateBlocksSelector.Mode.INCLUDE
		if not include:
			continue
		for setter in _parts_setters:
			if not setter:
				push_warning("Setter is null")
				continue
			setter.apply(block.slots)


func select_blocks(check_selection: Callable) -> RoommateBlocksSelector:
	var selector := RoommateBlocksSelector.new()
	selector.check_selection = check_selection
	_blocks_selectors.append(selector)
	return selector


func select_all_blocks() -> RoommateBlocksSelector:
	var _check_selection = func (block: RoommateBlock, source_blocks: Dictionary) -> bool:
		return true
	return select_blocks(_check_selection)


func select_edge_blocks(edge: Vector3i) -> RoommateBlocksSelector:
	var _check_selection = func (block: RoommateBlock, source_blocks: Dictionary) -> bool:
		var result := true
		if edge.x != 0:
			result = result and not source_blocks.has(block.block_position + edge * Vector3i.RIGHT)
		if edge.y != 0:
			result = result and not source_blocks.has(block.block_position + edge * Vector3i.UP)
		if edge.z != 0:
			result = result and not source_blocks.has(block.block_position + edge * Vector3i.BACK)
		return result
	return select_blocks(_check_selection)


func select_random_blocks(density: float, rng: RandomNumberGenerator = null) -> RoommateBlocksSelector:
	var clamped_density := clampf(density, 0, 1)
	var _check_selection = func (block: RoommateBlock, source_blocks: Dictionary) -> bool:
		var random_number := rng.randf() if rng else randf()
		return clamped_density >= random_number
	return select_blocks(_check_selection)


func select_parts(slot_ids: Array[StringName]) -> RoommatePartsSetter:
	var new_setter = RoommatePartsSetter.new()
	new_setter.selected_slot_ids = slot_ids
	_parts_setters.append(new_setter)
	return new_setter


func select_all_parts() -> RoommatePartsSetter:
	return select_parts([
		&"sid_center",
		&"sid_up",
		&"sid_down",
		&"sid_left",
		&"sid_right",
		&"sid_forward",
		&"sid_back",
	])


func select_all_walls() -> RoommatePartsSetter:
	return select_parts([
		&"sid_left",
		&"sid_right",
		&"sid_forward",
		&"sid_back",
	])


func select_center() -> RoommatePartsSetter:
	return select_parts([&"sid_center"])


func select_floor() -> RoommatePartsSetter:
	return select_parts([&"sid_down"])
