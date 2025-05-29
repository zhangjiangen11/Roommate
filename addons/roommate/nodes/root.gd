# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateRoot
extends MeshInstance3D

@export var block_size := 1.0:
	get:
		return block_size
	set(value):
		block_size = value
		generate_mesh()

@export var style: RoommateStyle

@export_group("Editor")
@export var nav_regions: Array[NavigationRegion3D]

var _tool := SurfaceTool.new()


func generate_mesh() -> void:
	# Searching for areas
	var nodes := find_children("*", "RoommateBlocksArea", true, false)
	var areas: Array[RoommateBlocksArea] = []
	areas.assign(nodes)
	areas.sort_custom(_sort_by_type)
	if areas.size() == 0:
		return
	
	# Creating all the blocks that defined by areas and applying styles
	var all_blocks := {}
	for area in areas:
		var area_blocks := area.create_blocks(block_size)
		all_blocks.merge(area_blocks, true)
	
	# Applying global style
	if style:
		style.build()
		style.apply(all_blocks)
	
	# Applying per area style
	var areas_with_style := areas.filter(_filter_by_style) as Array[RoommateBlocksArea]
	areas_with_style.sort_custom(_sort_by_style)
	for area in areas_with_style:
		var area_blocks := {}
		for area_block_position in area.get_block_positions(block_size):
			area_blocks[area_block_position] = all_blocks[area_block_position]
		area.style.build()
		area.style.apply(area_blocks)
	
	for block_position in all_blocks:
		var block := all_blocks[block_position] as RoommateBlock
		var part := block.slots["sid_up"] as RoommatePart
		print("%s: %s" % [block_position, part.transform.origin])
		
	var result := ArrayMesh.new()
	# TODO: generate
	mesh = result
	
	for nav_region in nav_regions:
		if nav_region:
			nav_region.bake_navigation_mesh()


func _sort_by_type(a: RoommateBlocksArea, b: RoommateBlocksArea) -> bool:
	if a is RoommateOutOfBounds:
		return false
	return true


func _sort_by_style(a: RoommateBlocksArea, b: RoommateBlocksArea) -> bool:
	return a.style.apply_order < b.style.apply_order


func _filter_by_style(a: RoommateBlocksArea) -> bool:
	return a.style != null
