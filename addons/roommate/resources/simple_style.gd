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

@export var simple_rulesets: Array[RoommateSimpleRuleset] = []


func _build_rulesets() -> void:
	for simple_ruleset in simple_rulesets:
		_build_simple_ruleset(simple_ruleset)


func _build_simple_ruleset(simple_ruleset: RoommateSimpleRuleset) -> void:
	if not simple_ruleset:
		return
	var ruleset := create_ruleset()
	
	var blocks_selector := ruleset.select_all_blocks()
	blocks_selector.offset = simple_ruleset.blocks_selector_offset
	
	var parts_selector := ruleset.select_parts(simple_ruleset.selected_parts)
	parts_selector.inverse_selection = simple_ruleset.inverse_selection
