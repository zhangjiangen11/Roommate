# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateBlocksSelector
extends RefCounted

enum Mode { INCLUDE, EXCLUDE }

var mode := Mode.INCLUDE
var check_selection: Callable


func check_block_inclusion(block: RoommateBlock, source_blocks: Dictionary) -> bool:
	var selected := check_selection.call(block, source_blocks) as bool
	return selected and mode == Mode.INCLUDE
