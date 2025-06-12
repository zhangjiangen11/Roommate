# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends RefCounted

enum Mode {
	INCLUDE,
	EXCLUDE,
	INVERT,
	INTERSECT,
}

var mode := Mode.INCLUDE
var out_of_bounds_allowed := false
var offset := Vector3i.ZERO
var check_selection: Callable


func update_inclusion(block: RoommateBlock, source_blocks: Dictionary, is_included: bool) -> bool:
	if not out_of_bounds_allowed and not RoommateBlock.in_bounds(block):
		return is_included
	if not check_selection.is_valid():
		push_error("check_selection is not valid")
		return is_included
	var offset_position := block.position - offset
	var is_selected := check_selection.call(offset_position, block, source_blocks)
	if not is_selected is bool:
		push_error("check_selection returned value of type %s. Bool expected" % typeof(is_selected))
		is_selected = false
	
	if not is_selected:
		if mode == Mode.INTERSECT:
			return false
		return is_included
	
	match mode:
		Mode.INCLUDE:
			return true
		Mode.EXCLUDE:
			return false
		Mode.INVERT:
			return not is_included
		Mode.INTERSECT:
			return is_included
	
	return is_included


func include() -> void:
	mode = Mode.INCLUDE


func exclude() -> void:
	mode = Mode.EXCLUDE


func invert() -> void:
	mode = Mode.INVERT


func intersect() -> void:
	mode = Mode.INTERSECT


func allow_out_of_bounds() -> void:
	out_of_bounds_allowed = true


func set_offset(new_offset: Vector3i) -> void:
	offset = new_offset
