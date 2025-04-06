# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateStyle
extends Resource

@export var rulesets: Array[RoommateRuleset] = []
@export var apply_priority := 0
var _current_rulesets: Array[RoommateRuleset] = []


func apply(source_blocks: RoommateBlocksArea.Blocks) -> void:
	_current_rulesets = rulesets
	if _current_rulesets.size() == 0:
		_build_rulesets()
	for ruleset in rulesets:
		if ruleset:
			ruleset.apply(source_blocks)


func get_all_materials() -> Array[Material]:
	var result: Array[Material] = []
	for ruleset in _current_rulesets:
		if not ruleset:
			continue
		var ruleset_materials := ruleset.get_materials()
		for material in ruleset_materials:
			if material and not material in result:
				result.append(material)
	return result


func select_all_blocks() -> RoommateRuleset:
	var ruleset := RoommateRuleset.new()
	ruleset.block_selectors.append(RoommateBlocksSelector.new())
	_current_rulesets.append(ruleset)
	return ruleset


func _build_rulesets() -> void: # virtual function
	pass
