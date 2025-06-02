# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateSurfaceOverrideSetter
extends RoommateObjectSetter

var material: RoommateValueSetter:
	get: return _resolve_value_setter(&"material")
var uv_offset: RoommateValueSetter:
	get: return _resolve_value_setter(&"uv_relative_position")
var uv_rotation: RoommateValueSetter:
	get: return _resolve_value_setter(&"uv_rotation")
var uv_scale: RoommateValueSetter:
	get: return _resolve_value_setter(&"uv_scale")


func apply(target: RoommateSurfaceOverride) -> void:
	_apply_to_object(target)


func set_uv_tile(tile_coord: Vector2i, tile_count: Vector2i, tile_rotation: float) -> void:
	var coord := tile_coord as Vector2
	var count := tile_count as Vector2
	
	var tile_size := Vector2.ONE / count
	var tile_offset := coord / count
	var rotated_offset := (tile_offset + tile_size / 2).rotated(-tile_rotation) - tile_size / 2
	
	uv_rotation.override(tile_rotation)
	uv_scale.override(tile_size)
	uv_offset.override(rotated_offset)
