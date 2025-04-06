# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommatePart
extends Resource

enum Action { UNDEFINED, INCLUDE, SKIP }

@export var action := Action.UNDEFINED
@export var mesh: Mesh
@export var material: Material

var _part_properties := {}

func set_values(other_part: RoommatePart) -> void:
	if not other_part:
		return
	if other_part.mesh:
		mesh = other_part.mesh
	if other_part.material:
		material = other_part.material
	if other_part.action != Action.UNDEFINED:
		action = other_part.action


func set_material(new_material: Material) -> RoommatePart:
	material = new_material
	return self
