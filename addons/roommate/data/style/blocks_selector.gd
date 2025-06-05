# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends RefCounted

var include_mode := true
var check_selection: Callable


func update_inclusion(block: RoommateBlock, source_blocks: Dictionary, is_included: bool) -> bool:
	if not check_selection.is_valid():
		push_error("check_selection is not valid")
		return is_included
	var is_selected := check_selection.call(block, source_blocks)
	if not is_selected is bool:
		push_error("check_selection returned value of type %s. Bool expected" % typeof(is_selected))
		is_selected = false
	if is_selected:
		is_included = include_mode
	return is_included


func include() -> void:
	include_mode = true


func exclude() -> void:
	include_mode = false
