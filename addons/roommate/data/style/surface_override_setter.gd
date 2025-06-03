# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateSurfaceOverrideSetter
extends "./object_setter.gd"

var material: RoommateValueSetter:
	get: return _resolve_value_setter(&"material")
var uv_transform: RoommateValueSetter:
	get: return _resolve_value_setter(&"uv_transform")


func apply(target: RoommateSurfaceOverride) -> void:
	_apply_to_object(target)


func set_uv_tile(tile_coord: Vector2i, tile_count: Vector2i, tile_rotation: float) -> void:
	var transform := RoommateSurfaceOverride.get_uv_tile_transform(tile_coord, tile_count, tile_rotation)
	uv_transform.override(transform)
