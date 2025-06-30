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
	var check_selection := func (offset_position: Vector3i, block: RoommateBlock, source_blocks: Dictionary) -> bool:
		return true
	return select_blocks(check_selection)


func select_blocks_by_type(type_id: StringName) -> BLOCKS_SELECTOR:
	var check_selection := func (offset_position: Vector3i, block: RoommateBlock, source_blocks: Dictionary) -> bool:
		return block.type_id == type_id
	return select_blocks(check_selection)


func select_edge_blocks(position_changes: Array[Vector3i], max_counts: Array[int]) -> BLOCKS_SELECTOR:
	var check_selection := func (offset_position: Vector3i, block: RoommateBlock, source_blocks: Dictionary) -> bool:
		if not source_blocks.has(offset_position):
			return false
		for i in position_changes.size():
			if max_counts.is_empty() or i != clampi(i, 0, max_counts.size() - 1) or max_counts[i] < 0:
				continue
			var count := RoommateBlock.raycast(offset_position, position_changes[i], source_blocks)
			if count > max_counts[i]:
				return false
		return true
	return select_blocks(check_selection)


func select_edge_blocks_axis(edge_size: Vector3i) -> BLOCKS_SELECTOR:
	var positions: Array[Vector3i] = []
	var counts: Array[int] = []
	if edge_size.x != 0:
		positions.append(Vector3i.RIGHT * edge_size.sign())
		counts.append(absi(edge_size.x) - 1)
	if edge_size.y != 0:
		positions.append(Vector3i.UP * edge_size.sign())
		counts.append(absi(edge_size.y) - 1)
	if edge_size.z != 0:
		positions.append(Vector3i.BACK * edge_size.sign())
		counts.append(absi(edge_size.z) - 1)
	return select_edge_blocks(positions, counts)


func select_interval_blocks(interval: Vector3i) -> BLOCKS_SELECTOR:
	var check_selection := func (offset_position: Vector3i, block: RoommateBlock, source_blocks: Dictionary) -> bool:
		return offset_position.snapped(interval) == offset_position
	return select_blocks(check_selection)


func select_inner_blocks(position_changes: Array[Vector3i], tolerances: Array[int]) -> BLOCKS_SELECTOR:
	var check_selection := func (offset_position: Vector3i, block: RoommateBlock, source_blocks: Dictionary) -> bool:
		if not source_blocks.has(offset_position):
			return false
		for i in position_changes.size():
			if tolerances.is_empty() or i != clampi(i, 0, tolerances.size() - 1) or tolerances[i] < 0:
				continue
			var forward_count := RoommateBlock.raycast(offset_position, position_changes[i], source_blocks)
			var back_count := RoommateBlock.raycast(offset_position, -position_changes[i], source_blocks)
			if absi(forward_count - back_count) > tolerances[i]:
				return false
		return true
	return select_blocks(check_selection)


func select_inner_blocks_uniform(position_changes: Array[Vector3i], uniform_tolerance: int) -> BLOCKS_SELECTOR:
	var tolerances: Array[int] = []
	tolerances.resize(position_changes.size())
	tolerances.fill(uniform_tolerance)
	return select_inner_blocks(position_changes, tolerances)


func select_inner_blocks_axis(axis_tolerances: Vector3i) -> BLOCKS_SELECTOR:
	var position_changes: Array[Vector3i] = [Vector3i.RIGHT, Vector3i.UP, Vector3i.BACK]
	var tolerances: Array[int] = [axis_tolerances.x, axis_tolerances.y, axis_tolerances.z]
	return select_inner_blocks(position_changes, tolerances)


func select_random_blocks(density: float, rng: RandomNumberGenerator = null) -> BLOCKS_SELECTOR:
	var clamped_density := clampf(density, 0, 1)
	var check_selection := func (offset_position: Vector3i, block: RoommateBlock, source_blocks: Dictionary) -> bool:
		var random_number := rng.randf() if rng else randf()
		return clamped_density >= random_number
	return select_blocks(check_selection)


func select_parts(slot_ids: Array[StringName]) -> PARTS_SETTER:
	var new_setter = PARTS_SETTER.new()
	new_setter.selected_slot_ids = slot_ids
	_parts_setters.append(new_setter)
	return new_setter


func select_part(slot_id: StringName) -> PARTS_SETTER:
	return select_parts([slot_id])


func select_all_parts() -> PARTS_SETTER:
	var setter := select_parts([])
	setter.inverse_selection = true
	return setter


func select_all_walls() -> PARTS_SETTER:
	return select_parts([
		RoommateBlock.WALL_LEFT_SLOT,
		RoommateBlock.WALL_RIGHT_SLOT,
		RoommateBlock.WALL_FORWARD_SLOT,
		RoommateBlock.WALL_BACK_SLOT,
	])


func select_ceil() -> PARTS_SETTER:
	return select_parts([RoommateBlock.CEIL_SLOT])


func select_floor() -> PARTS_SETTER:
	return select_parts([RoommateBlock.FLOOR_SLOT])


func select_wall_left() -> PARTS_SETTER:
	return select_parts([RoommateBlock.WALL_LEFT_SLOT])


func select_wall_right() -> PARTS_SETTER:
	return select_parts([RoommateBlock.WALL_RIGHT_SLOT])


func select_wall_forward() -> PARTS_SETTER:
	return select_parts([RoommateBlock.WALL_FORWARD_SLOT])


func select_wall_back() -> PARTS_SETTER:
	return select_parts([RoommateBlock.WALL_BACK_SLOT])


func select_center() -> PARTS_SETTER:
	return select_parts([RoommateBlock.CENTER_SLOT])


func select_oblique() -> PARTS_SETTER:
	return select_parts([RoommateBlock.OBLIQUE_SLOT])
