# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
@icon("../icons/styler.svg")
class_name RoommateStyler
extends Node3D

@export var style: RoommateStyle
@export var style_apply_order := 0


static func get_class_name() -> StringName:
	return &"RoommateStyler"


func apply_style(all_blocks: Dictionary, root_transform: Transform3D, 
		block_size: float) -> void:
	if not style:
		return
	var area_blocks := {}
	for block_position in all_blocks:
		if _check_block_for_style(all_blocks[block_position], all_blocks,
				root_transform, block_size):
			area_blocks[block_position] = all_blocks[block_position]
	style.apply(area_blocks)


func _check_block_for_style(block: RoommateBlock, all_blocks: Dictionary, 
		root_transform: Transform3D, block_size: float) -> bool:
	return true # virtual method
