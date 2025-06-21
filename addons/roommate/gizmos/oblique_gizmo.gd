# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
extends "./area_edit_gizmo.gd"


func _redraw() -> void:
	clear()
	_draw_area_edit()
	var blocks_material := get_plugin().get_material("blocks", self)
	add_lines([Vector3(0, 0, 0), Vector3(0, 0, -1)], blocks_material)
