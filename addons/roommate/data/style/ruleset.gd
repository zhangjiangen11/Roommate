# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends RefCounted

const BLOCKS_SELECTOR := preload("./blocks_selector.gd")
const PARTS_SETTER := preload("./parts_setter.gd")

var _blocks_selectors: Array[BLOCKS_SELECTOR] = []
var _parts_setters: Array[PARTS_SETTER] = []


func apply(source_blocks: Dictionary) -> void:
	if _blocks_selectors.size() == 0:
		push_warning("Ruleset doesnt have blocks selectors.")
	if _parts_setters.size() == 0:
		push_warning("Ruleset doesnt have parts setters.")
	for block_position in source_blocks:
		var include := false
		var block := source_blocks[block_position] as RoommateBlock
		for blocks_selector in _blocks_selectors:
			include = blocks_selector.update_inclusion(block, source_blocks, include)
		if not include:
			continue
		for setter in _parts_setters:
			if not setter:
				push_warning("Parts setter is null.")
				continue
			setter.apply(block)


func select_blocks(check_selection: Callable) -> BLOCKS_SELECTOR:
	var selector := BLOCKS_SELECTOR.new()
	selector.check_selection = check_selection
	_blocks_selectors.append(selector)
	return selector


func select_all_blocks() -> BLOCKS_SELECTOR:
	var check_selection := func (block: RoommateBlock, source_blocks: Dictionary) -> bool:
		return true
	return select_blocks(check_selection)


func select_edge_blocks(relative_positions: Array[Vector3i]) -> BLOCKS_SELECTOR:
	var check_selection := func (block: RoommateBlock, source_blocks: Dictionary) -> bool:
		for relative_position in relative_positions:
			var next_block := source_blocks.get(block.position + relative_position) as RoommateBlock
			if RoommateBlock.in_bounds(next_block):
				return false
		return true
	return select_blocks(check_selection)


func select_edge_blocks_axis(edge: Vector3i) -> BLOCKS_SELECTOR:
	var positions: Array[Vector3i] = []
	if edge.x != 0:
		positions.append(edge * Vector3i.RIGHT)
	if edge.y != 0:
		positions.append(edge * Vector3i.UP)
	if edge.z != 0:
		positions.append(edge * Vector3i.BACK)
	return select_edge_blocks(positions)


func select_interval_blocks(interval: Vector3i, offset := Vector3i.ZERO) -> BLOCKS_SELECTOR:
	var check_selection := func (block: RoommateBlock, source_blocks: Dictionary) -> bool:
		var offset_position := block.position - offset
		return offset_position.snapped(interval) == offset_position
	return select_blocks(check_selection)


func select_inner_blocks(position_changes: Array[Vector3i], tolerances: Array[int], offset := Vector3i.ZERO) -> BLOCKS_SELECTOR:
	var count_blocks := func (start: Vector3i, position_change: Vector3i, source_blocks: Dictionary) -> int:
		var result := 0
		var block := source_blocks.get(start + position_change) as RoommateBlock
		while RoommateBlock.in_bounds(block):
			result += 1
			block = source_blocks.get(block.position + position_change) as RoommateBlock
		return result
	var get_difference := func (start: Vector3i, position_change: Vector3i, source_blocks: Dictionary) -> int:
		var forward_count := count_blocks.call(start, position_change, source_blocks)
		var back_count := count_blocks.call(start, -position_change, source_blocks)
		return absi(forward_count - back_count)
	var check_selection := func (block: RoommateBlock, source_blocks: Dictionary) -> bool:
		var offset_position := block.position - offset
		var offset_block := source_blocks.get(offset_position) as RoommateBlock
		if not RoommateBlock.in_bounds(offset_block):
			return false
		for i in position_changes.size():
			if tolerances.is_empty() or i != clampi(i, 0, tolerances.size() - 1) or tolerances[i] < 0:
				continue
			if get_difference.call(offset_position, position_changes[i], source_blocks) > tolerances[i]:
				return false
		return true
	return select_blocks(check_selection)


func select_inner_blocks_uniform(position_changes: Array[Vector3i], uniform_tolerance: int, offset := Vector3i.ZERO) -> BLOCKS_SELECTOR:
	var tolerances: Array[int] = []
	tolerances.resize(position_changes.size())
	tolerances.fill(uniform_tolerance)
	return select_inner_blocks(position_changes, tolerances, offset)


func select_inner_blocks_axis(axis_tolerances: Vector3i, offset := Vector3i.ZERO) -> BLOCKS_SELECTOR:
	var position_changes: Array[Vector3i] = [Vector3i.RIGHT, Vector3i.UP, Vector3i.BACK]
	var tolerances: Array[int] = [axis_tolerances.x, axis_tolerances.y, axis_tolerances.z]
	return select_inner_blocks(position_changes, tolerances, offset)


func select_random_blocks(density: float, rng: RandomNumberGenerator = null) -> BLOCKS_SELECTOR:
	var clamped_density := clampf(density, 0, 1)
	var check_selection := func (block: RoommateBlock, source_blocks: Dictionary) -> bool:
		var random_number := rng.randf() if rng else randf()
		return clamped_density >= random_number
	return select_blocks(check_selection)


func select_parts(slot_ids: Array[StringName]) -> PARTS_SETTER:
	var new_setter = PARTS_SETTER.new()
	new_setter.selected_slot_ids = slot_ids
	_parts_setters.append(new_setter)
	return new_setter


func select_all_parts() -> PARTS_SETTER:
	return select_parts([
		RoommateBlock.CEIL,
		RoommateBlock.FLOOR,
		RoommateBlock.WALL_LEFT,
		RoommateBlock.WALL_RIGHT,
		RoommateBlock.WALL_FORWARD,
		RoommateBlock.WALL_BACK,
		RoommateBlock.CENTER,
	])


func select_all_walls() -> PARTS_SETTER:
	return select_parts([
		RoommateBlock.WALL_LEFT,
		RoommateBlock.WALL_RIGHT,
		RoommateBlock.WALL_FORWARD,
		RoommateBlock.WALL_BACK,
	])


func select_ceil() -> PARTS_SETTER:
	return select_parts([RoommateBlock.CEIL])


func select_floor() -> PARTS_SETTER:
	return select_parts([RoommateBlock.FLOOR])


func select_wall_left() -> PARTS_SETTER:
	return select_parts([RoommateBlock.WALL_LEFT])


func select_wall_right() -> PARTS_SETTER:
	return select_parts([RoommateBlock.WALL_RIGHT])


func select_wall_forward() -> PARTS_SETTER:
	return select_parts([RoommateBlock.WALL_FORWARD])


func select_wall_back() -> PARTS_SETTER:
	return select_parts([RoommateBlock.WALL_BACK])


func select_center() -> PARTS_SETTER:
	return select_parts([RoommateBlock.CENTER])
