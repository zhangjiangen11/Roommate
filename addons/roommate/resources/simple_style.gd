# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
@icon("../icons/style.svg")
class_name RoommateSimpleStyle
extends RoommateStyle

@export var selected_parts: Array[StringName] = [
	RoommateBlock.Slot.CEIL,
	RoommateBlock.Slot.FLOOR,
	RoommateBlock.Slot.WALL_LEFT,
	RoommateBlock.Slot.WALL_RIGHT,
	RoommateBlock.Slot.WALL_FORWARD,
	RoommateBlock.Slot.WALL_BACK,
	RoommateBlock.Slot.CENTER,
	RoommateBlock.Slot.OBLIQUE,
]


func _build_rulesets() -> void:
	var ruleset := create_ruleset()
	ruleset.select_all_blocks()
