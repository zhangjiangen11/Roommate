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

const RANDOM_DENSITY := 0.5
# sbsid - simple blocks selector id
const BLOCKS_SELECTOR_ALL := &"sbsid_all"
const BLOCKS_SELECTOR_SPACE_TYPE := &"sbsid_space_type"
const BLOCKS_SELECTOR_OBLIQUE_TYPE := &"sbsid_oblique_type"
const BLOCKS_SELECTOR_EXTREME := &"sbsid_extreme"
const BLOCKS_SELECTOR_EDGE := &"sbsid_edge"
const BLOCKS_SELECTOR_INTERVAL := &"sbsid_interval"
const BLOCKS_SELECTOR_INNER := &"sbsid_inner"
const BLOCKS_SELECTOR_RANDOM := &"sbsid_random"

@export_group("Blocks Selector")
@export_enum("All Blocks", "Only Space Blocks", "Only Oblique Blocks", 
		"Blocks On Extreme Positions", "Edge Blocks", "Blocks On Interval", 
		"Inner Blocks", "Random Blocks") var blocks_selector: String:
	set(value):
		const SELECTOR_MAP := {
			"All Blocks": BLOCKS_SELECTOR_ALL,
			"Only Space Blocks": BLOCKS_SELECTOR_SPACE_TYPE,
			"Only Oblique Blocks": BLOCKS_SELECTOR_OBLIQUE_TYPE,
			"Blocks On Extreme Positions": BLOCKS_SELECTOR_EXTREME,
			"Edge Blocks": BLOCKS_SELECTOR_EDGE,
			"Blocks On Interval": BLOCKS_SELECTOR_INTERVAL,
			"Inner Blocks": BLOCKS_SELECTOR_INNER,
			"Random Blocks": BLOCKS_SELECTOR_RANDOM,
		}
		blocks_selector = value
		_blocks_selector_id = SELECTOR_MAP[value]
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
@export var part_scale := Vector3.ONE

@export var mesh: Mesh = null
@export var collision_mesh: Mesh = null
@export var nav_mesh: Mesh = null

@export var material: Material = null
@export var color := Color.WHITE

var _blocks_selector_id := BLOCKS_SELECTOR_ALL
