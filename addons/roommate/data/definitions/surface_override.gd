# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateSurfaceOverride
extends RefCounted

var material: Material
var uv_transform := Transform2D.IDENTITY


func set_uv_tile(tile_coord: Vector2i, tile_count: Vector2i, tile_rotation: float) -> void:
	uv_transform = get_uv_tile_transform(tile_coord, tile_count, tile_rotation)


static func get_uv_tile_transform(tile_coord: Vector2i, tile_count: Vector2i, 
		tile_rotation: float) -> Transform2D:
	var coord := tile_coord as Vector2
	var count := tile_count as Vector2
	var tile_size := Vector2.ONE / count
	var tile_offset := coord / count
	var rotated_offset := (tile_offset + tile_size / 2).rotated(-tile_rotation) - tile_size / 2
	return Transform2D(tile_rotation, Vector2.ZERO) * Transform2D(0, tile_size, 0, rotated_offset)
