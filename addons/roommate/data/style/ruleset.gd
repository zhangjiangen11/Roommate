# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends RefCounted

const BLOCKS_SELECTOR := preload("./blocks_selectors/blocks_selector.gd")
const PARTS_SETTER := preload("./object_setters/parts_setter.gd")

var _blocks_selectors: Array[BLOCKS_SELECTOR] = []
var _parts_setters: Array[PARTS_SETTER] = []


func apply(source_blocks: Dictionary) -> void:
	if _blocks_selectors.size() == 0:
		push_warning("ROOMMATE: Ruleset doesn't have blocks selectors.")
	if _parts_setters.size() == 0:
		push_warning("ROOMMATE: Ruleset doesn't have parts setters.")
	for blocks_selector in _blocks_selectors:
		blocks_selector.prepare(source_blocks)
	for block_position in source_blocks:
		var include := false
		var block := source_blocks[block_position] as RoommateBlock
		for blocks_selector in _blocks_selectors:
			include = blocks_selector.update_inclusion(block, source_blocks, include)
		if not include:
			continue
		for setter in _parts_setters:
			if not setter:
				push_warning("ROOMMATE: Parts setter is null.")
				continue
			setter.apply(block)


func select_blocks(check_selection: Callable, prepare_vars := Callable()) -> BLOCKS_SELECTOR:
	return _add_blocks_selector(preload("./blocks_selectors/custom_blocks_selector.gd").new(check_selection, 
			prepare_vars))


func select_all_blocks() -> BLOCKS_SELECTOR:
	return _add_blocks_selector(preload("./blocks_selectors/all_blocks_selector.gd").new())


func select_blocks_by_type(type_id: StringName) -> BLOCKS_SELECTOR:
	return _add_blocks_selector(preload("./blocks_selectors/type_blocks_selector.gd").new(type_id))


func select_blocks_by_extreme(axis: Vector3) -> BLOCKS_SELECTOR:
	return _add_blocks_selector(preload("./blocks_selectors/extreme_blocks_selector.gd").new(axis))


func select_edge_blocks(segments: Array[RoommateSegment]) -> BLOCKS_SELECTOR:
	return _add_blocks_selector(preload("./blocks_selectors/edge_blocks_selector.gd").new(segments))


func select_edge_blocks_axis(edge_size: Vector3i) -> BLOCKS_SELECTOR:
	var segments: Array[RoommateSegment] = []
	if edge_size.x != 0:
		segments.append(RoommateSegment.new(Vector3i.RIGHT * edge_size.sign(), 
				absi(edge_size.x) - 1))
	if edge_size.y != 0:
		segments.append(RoommateSegment.new(Vector3i.UP * edge_size.sign(),
				absi(edge_size.y) - 1))
	if edge_size.z != 0:
		segments.append(RoommateSegment.new(Vector3i.BACK * edge_size.sign(),
				absi(edge_size.z) - 1))
	return select_edge_blocks(segments)


func select_interval_blocks(interval: Vector3i) -> BLOCKS_SELECTOR:
	return _add_blocks_selector(preload("./blocks_selectors/interval_blocks_selector.gd").new(interval))


func select_inner_blocks(segments: Array[RoommateSegment]) -> BLOCKS_SELECTOR:
	return _add_blocks_selector(preload("./blocks_selectors/inner_blocks_selector.gd").new(segments))


func select_inner_blocks_uniform(steps: Array[Vector3i], uniform_tolerance: int) -> BLOCKS_SELECTOR:
	var segments: Array[RoommateSegment] = []
	for step in steps:
		segments.append(RoommateSegment.new(step, uniform_tolerance))
	return select_inner_blocks(segments)


func select_inner_blocks_axis(axis_tolerances: Vector3i) -> BLOCKS_SELECTOR:
	var segments: Array[RoommateSegment] = [
		RoommateSegment.new(Vector3i.RIGHT, axis_tolerances.x),
		RoommateSegment.new(Vector3i.UP, axis_tolerances.y),
		RoommateSegment.new(Vector3i.BACK, axis_tolerances.z),
	]
	return select_inner_blocks(segments)


func select_random_blocks(density: float, rng: RandomNumberGenerator = null) -> BLOCKS_SELECTOR:
	return _add_blocks_selector(preload("./blocks_selectors/random_blocks_selector.gd").new(density, 
			rng))


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
		RoommateBlock.Slot.WALL_LEFT,
		RoommateBlock.Slot.WALL_RIGHT,
		RoommateBlock.Slot.WALL_FORWARD,
		RoommateBlock.Slot.WALL_BACK,
	])


func select_ceil() -> PARTS_SETTER:
	return select_part(RoommateBlock.Slot.CEIL)


func select_floor() -> PARTS_SETTER:
	return select_part(RoommateBlock.Slot.FLOOR)


func select_wall_left() -> PARTS_SETTER:
	return select_part(RoommateBlock.Slot.WALL_LEFT)


func select_wall_right() -> PARTS_SETTER:
	return select_part(RoommateBlock.Slot.WALL_RIGHT)


func select_wall_forward() -> PARTS_SETTER:
	return select_part(RoommateBlock.Slot.WALL_FORWARD)


func select_wall_back() -> PARTS_SETTER:
	return select_part(RoommateBlock.Slot.WALL_BACK)


func select_center() -> PARTS_SETTER:
	return select_part(RoommateBlock.Slot.CENTER)


func select_oblique() -> PARTS_SETTER:
	return select_part(RoommateBlock.Slot.OBLIQUE)


func _add_blocks_selector(selector: BLOCKS_SELECTOR) -> BLOCKS_SELECTOR:
	_blocks_selectors.append(selector)
	return selector
