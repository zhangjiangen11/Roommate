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


func set_uv_tile(tile_coord: Vector2i, tile_size: Vector2i, tile_rotation: float) -> void:
	var coord := tile_coord as Vector2
	var size := tile_size as Vector2
	var rotated_coord := (coord + Vector2.ONE / 2).rotated(-tile_rotation) - Vector2.ONE / 2
	uv_rotation = tile_rotation
	uv_scale = Vector2.ONE / size
	uv_relative_position = rotated_coord / size
