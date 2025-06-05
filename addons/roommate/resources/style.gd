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

const RULESET := preload("../data/style/ruleset.gd")

@export var apply_order := 0

var _current_rulesets: Array[RULESET] = []


func apply(source_blocks: Dictionary) -> void:
	_current_rulesets.clear()
	_build_rulesets()
	for ruleset in _current_rulesets:
		ruleset.apply(source_blocks)


func create_ruleset() -> RULESET:
	var new_ruleset = RULESET.new()
	_current_rulesets.append(new_ruleset)
	return new_ruleset


func _build_rulesets() -> void: # virtual function
	pass
