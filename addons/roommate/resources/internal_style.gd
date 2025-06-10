# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends RoommateStyle

var scale := Vector3.ONE
var force_white_vertex_color := false


func _build_rulesets() -> void:
	var ruleset := create_ruleset()
	ruleset.select_all_blocks()
	var parts := ruleset.select_all_parts()
	parts.transform.accumulate(Transform3D.IDENTITY.scaled(scale))
	if force_white_vertex_color:
		parts.override_fallback_surface().set_color(Color.WHITE)
