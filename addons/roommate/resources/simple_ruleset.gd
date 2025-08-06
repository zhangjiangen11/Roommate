# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateSimpleRuleset
extends Resource

# sbsid - simple blocks selector id
const BLOCKS_SELECTOR_ALL := &"sbsid_all"
const BLOCKS_SELECTOR_SPACE_TYPE := &"sbsid_space_type"
const BLOCKS_SELECTOR_OBLIQUE_TYPE := &"sbsid_oblique_type"
const BLOCKS_SELECTOR_EXTREME := &"sbsid_extreme"
const BLOCKS_SELECTOR_EDGE := &"sbsid_edge"
const BLOCKS_SELECTOR_INTERVAL := &"sbsid_interval"
const BLOCKS_SELECTOR_INNER := &"sbsid_inner"
const BLOCKS_SELECTOR_RANDOM := &"sbsid_random"
const BLOCKS_SELECTOR_SEEDED_RANDOM := &"sbsid_seeded_random"

@export_group("Blocks Selector")
@export_enum(BLOCKS_SELECTOR_ALL, BLOCKS_SELECTOR_SPACE_TYPE, BLOCKS_SELECTOR_OBLIQUE_TYPE, 
		BLOCKS_SELECTOR_EXTREME, BLOCKS_SELECTOR_EDGE, BLOCKS_SELECTOR_INTERVAL, 
		BLOCKS_SELECTOR_INNER, BLOCKS_SELECTOR_RANDOM) var blocks_selector := String(BLOCKS_SELECTOR_ALL)
@export var blocks_selector_step := Vector3i.ZERO
@export var blocks_selector_offset := Vector3i.ZERO

@export_group("Parts Setter")
@export var selected_parts: Array[StringName] = [
	RoommateBlock.Slot.CEIL,
	RoommateBlock.Slot.FLOOR,
	RoommateBlock.Slot.WALL_LEFT,
	RoommateBlock.Slot.WALL_RIGHT,
	RoommateBlock.Slot.WALL_FORWARD,
	RoommateBlock.Slot.WALL_BACK,
	RoommateBlock.Slot.CENTER,
	RoommateBlock.Slot.OBLIQUE,
]
@export var inverse_selection := false

@export_group("Overrides")
@export var part_position_offset := Vector3.ZERO
@export var part_rotation_offset := Vector3.ZERO
@export var part_scale_offset := Vector3.ONE

@export var mesh: Mesh = null
@export var collision_mesh: Mesh = null
@export var nav_mesh: Mesh = null

@export var scene: PackedScene
@export var scene_path: NodePath
@export var scene_properties: Dictionary

@export var material: Material = null
@export var color := Color.WHITE
