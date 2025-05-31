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


func apply(slots: Dictionary) -> void:
	for slot_id in slots:
		if not slot_id in selected_slot_ids:
			continue
		var current_part := slots.get(slot_id) as RoommatePart
		if not current_part:
			continue
		for property_name in _new_values:
			current_part.set(property_name, _new_values[property_name])
		
		for surface_id in _material_overrides:
			if not _material_overrides.has(surface_id):
				continue
				
			var new_override_values := _material_overrides[surface_id] as Dictionary
			var current_override := current_part.material_overrides.get(surface_id) as RoommatePart.MaterialOverride
			if not current_override:
				current_override = RoommatePart.MaterialOverride.new()
				current_part.material_overrides[surface_id] = current_override
			for property_name in new_override_values:
				current_override.set(property_name, new_override_values[property_name])
		
		if handle_part:
			handle_part.call(current_part)


func set_offset(offset: Vector3) -> void:
	_new_values[&"relative_position"] = offset


func set_rotation(rotation: Vector3) -> void:
	_new_values[&"rotation"] = rotation


func set_scale(scale: Vector3) -> void:
	_new_values[&"scale"] = scale


func set_collision_offset(offset: Vector3) -> void:
	_new_values[&"collision_relative_position"] = offset


func set_collision_rotation(rotation: Vector3) -> void:
	_new_values[&"collision_rotation"] = rotation


func set_collision_scale(scale: Vector3) -> void:
	_new_values[&"collision_scale"] = scale


func set_material(material: Material, surface_id: int) -> void:
	var override := _get_or_create_material_override(surface_id)
	override[&"material"] = material


func set_uv_offset(offset: Vector2, surface_id: int) -> void:
	var override := _get_or_create_material_override(surface_id)
	override[&"uv_relative_position"] = offset


func set_uv_rotation(rotation: float, surface_id: int) -> void:
	var override := _get_or_create_material_override(surface_id)
	override[&"uv_rotation"] = rotation


func set_uv_scale(scale: Vector2, surface_id: int) -> void:
	var override := _get_or_create_material_override(surface_id)
	override[&"uv_scale"] = scale


func set_uv_tile(tile_coord: Vector2i, tile_size: Vector2i, surface_id: int) -> void:
	set_uv_scale(Vector2.ONE / (tile_size as Vector2), surface_id)
	set_uv_offset((tile_coord as Vector2) / (tile_size as Vector2), surface_id)


func set_mesh(mesh: Mesh) -> void:
	_new_values[&"mesh"] = mesh


func set_collision_mesh(mesh: Mesh) -> void:
	_new_values[&"collision_mesh"] = mesh


func _get_or_create_material_override(surface_id: int) -> Dictionary:
	if _material_overrides.has(surface_id):
		return _material_overrides[surface_id] as Dictionary
	var new_override := {}
	_material_overrides[surface_id] = new_override
	return new_override
