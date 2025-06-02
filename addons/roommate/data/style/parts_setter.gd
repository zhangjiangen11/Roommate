# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommatePartsSetter
extends RefCounted

var selected_slot_ids: Array[StringName] = []
var handle_part: Callable
var _new_values := {}
var _material_overrides := {}


func apply(block: RoommateBlock) -> void:
	for slot_id in block.slots:
		if not slot_id in selected_slot_ids:
			continue
		var current_part := block.slots.get(slot_id) as RoommatePart
		if not current_part:
			continue
		for property_name in _new_values:
			current_part.set(property_name, _new_values[property_name])
		
		for surface_id in _material_overrides:
			var new_override_values := _material_overrides[surface_id] as Dictionary
			var current_override := current_part.resolve_material_override(surface_id)
			for property_name in new_override_values:
				current_override.set(property_name, new_override_values[property_name])
		
		if handle_part:
			handle_part.call(current_part)


func set_offset(offset: Vector3) -> void:
	_new_values[&"relative_position"] = offset


func set_rotation(rotation: Vector3) -> void:
	_new_values[&"rotation"] = rotation


func set_relative_rotation(rotation: Vector3) -> void:
	_new_values[&"relative_rotation"] = rotation


func set_scale(scale: Vector3) -> void:
	_new_values[&"scale"] = scale


func set_collision_offset(offset: Vector3) -> void:
	_new_values[&"collision_relative_position"] = offset


func set_collision_rotation(rotation: Vector3) -> void:
	_new_values[&"collision_rotation"] = rotation


func set_collision_relative_rotation(rotation: Vector3) -> void:
	_new_values[&"collision_relative_rotation"] = rotation


func set_collision_scale(scale: Vector3) -> void:
	_new_values[&"collision_scale"] = scale


func set_material(material: Material, surface_id: int) -> void:
	var override := _resolve_material_override(surface_id)
	override[&"material"] = material


func set_uv_offset(offset: Vector2, surface_id: int) -> void:
	var override := _resolve_material_override(surface_id)
	override[&"uv_relative_position"] = offset


func set_uv_rotation(rotation: float, surface_id: int) -> void:
	var override := _resolve_material_override(surface_id)
	override[&"uv_rotation"] = rotation


func set_uv_scale(scale: Vector2, surface_id: int) -> void:
	var override := _resolve_material_override(surface_id)
	override[&"uv_scale"] = scale


func set_uv_tile(tile_coord: Vector2i, tile_count: Vector2i, tile_rotation: float, surface_id: int) -> void:
	var coord := tile_coord as Vector2
	var count := tile_count as Vector2
	
	var tile_size := Vector2.ONE / count
	var tile_offset := coord / count
	var rotated_offset := (tile_offset + tile_size / 2).rotated(-tile_rotation) - tile_size / 2
	
	set_uv_rotation(tile_rotation, surface_id)
	set_uv_scale(tile_size, surface_id)
	set_uv_offset(rotated_offset, surface_id)


func set_mesh(mesh: Mesh) -> void:
	_new_values[&"mesh"] = mesh


func set_collision_mesh(mesh: Mesh) -> void:
	_new_values[&"collision_mesh"] = mesh


func _resolve_material_override(surface_id: int) -> Dictionary:
	if _material_overrides.has(surface_id):
		return _material_overrides[surface_id] as Dictionary
	var new_override := {}
	_material_overrides[surface_id] = new_override
	return new_override
