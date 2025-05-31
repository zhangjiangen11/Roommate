# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommatePart
extends RefCounted

var anchor := Vector3.ZERO

var relative_position := Vector3.ZERO
var rotation := Vector3.ZERO
var scale := Vector3.ONE

var collision_relative_position := Vector3.ZERO
var collision_rotation := Vector3.ZERO
var collision_scale := Vector3.ONE

var mesh: Mesh
var collision_mesh: Mesh
var material_overrides: Dictionary


func get_transform(origin: Vector3) -> Transform3D:
	var basis := Basis.from_euler(rotation).scaled(scale)
	return Transform3D(basis, origin + relative_position)


func get_collision_transform(origin: Vector3) -> Transform3D:
	var basis := Basis.from_euler(collision_rotation).scaled(collision_scale)
	return Transform3D(basis, origin + collision_relative_position)


class MaterialOverride:
	extends RefCounted
	
	var material: Material
	var uv_relative_position := Vector2.ZERO
	var uv_rotation := 0.0
	var uv_scale := Vector2.ONE
	
	
	func get_uv_transform() -> Transform2D:
		return Transform2D(uv_rotation, uv_scale, 0, uv_relative_position)
	
	
	func set_uv_tile(tile_coord: Vector2i, tile_size: Vector2i) -> void:
		uv_scale = Vector2.ONE / (tile_size as Vector2)
		uv_relative_position = (tile_coord as Vector2) / (tile_size as Vector2)
