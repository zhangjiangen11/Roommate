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
var direction := Vector3.ZERO
var roll_rotation := 0.0

var transform := Transform3D.IDENTITY
var collision_transform := Transform3D.IDENTITY

var mesh: Mesh
var collision_mesh: Mesh
var _surface_overrides: Dictionary


func resolve_surface_override(surface_id: int) -> RoommateSurfaceOverride:
	if not _surface_overrides.has(surface_id):
		var new_override := RoommateSurfaceOverride.new()
		_surface_overrides[surface_id] = new_override
		return new_override
	return _surface_overrides[surface_id] as RoommateSurfaceOverride
