# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateMaterialOverride
extends RefCounted

var material: Material
var uv_relative_position := Vector2.ZERO
var uv_rotation := 0.0
var uv_scale := Vector2.ONE


func get_uv_transform() -> Transform2D:
	return Transform2D(uv_rotation, Vector2.ZERO) * Transform2D(0.0, uv_scale, 0.0, uv_relative_position)


func set_uv_tile(tile_coord: Vector2i, tile_count: Vector2i, tile_rotation: float) -> void:	
	var coord := tile_coord as Vector2
	var count := tile_count as Vector2
	
	var tile_size := Vector2.ONE / count
	var tile_offset := coord / count
	var rotated_offset := (tile_offset + tile_size / 2).rotated(-tile_rotation) - tile_size / 2
	
	uv_rotation = tile_rotation
	uv_scale = tile_size
	uv_relative_position = rotated_offset
