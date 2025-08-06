# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
@icon("../icons/style.svg")
class_name RoommateSimpleStyle
extends RoommateStyle

const _BLOCK_SELECTOR := preload("../data/style/blocks_selectors/blocks_selector.gd")

@export var simple_rulesets: Array[RoommateSimpleRuleset] = []


func _build_rulesets() -> void:
	for simple_ruleset in simple_rulesets:
		_build_simple_ruleset(simple_ruleset)


func _build_simple_ruleset(simple_ruleset: RoommateSimpleRuleset) -> void:
	const RANDOM_DENSITY := 0.5
	
	if not simple_ruleset:
		return
	var ruleset := create_ruleset()
	
	var blocks_selector: _BLOCK_SELECTOR = null
	match StringName(simple_ruleset.blocks_selector):
		RoommateSimpleRuleset.BLOCKS_SELECTOR_ALL:
			blocks_selector = ruleset.select_all_blocks()
		RoommateSimpleRuleset.BLOCKS_SELECTOR_SPACE_TYPE:
			blocks_selector = ruleset.select_blocks_by_type(RoommateBlock.SPACE_TYPE)
		RoommateSimpleRuleset.BLOCKS_SELECTOR_OBLIQUE_TYPE:
			blocks_selector = ruleset.select_blocks_by_type(RoommateBlock.OBLIQUE_TYPE)
		RoommateSimpleRuleset.BLOCKS_SELECTOR_EXTREME:
			blocks_selector = ruleset.select_blocks_by_extreme(simple_ruleset.blocks_selector_step)
		RoommateSimpleRuleset.BLOCKS_SELECTOR_EDGE:
			blocks_selector = ruleset.select_edge_blocks_axis(simple_ruleset.blocks_selector_step)
		RoommateSimpleRuleset.BLOCKS_SELECTOR_INTERVAL:
			blocks_selector = ruleset.select_interval_blocks(simple_ruleset.blocks_selector_step)
		RoommateSimpleRuleset.BLOCKS_SELECTOR_INNER:
			blocks_selector = ruleset.select_inner_blocks_axis(simple_ruleset.blocks_selector_step)
		RoommateSimpleRuleset.BLOCKS_SELECTOR_RANDOM:
			blocks_selector = ruleset.select_random_blocks(RANDOM_DENSITY)
		RoommateSimpleRuleset.BLOCKS_SELECTOR_SEEDED_RANDOM:
			var rng := RandomNumberGenerator.new()
			rng.seed = hash("Roommate")
			blocks_selector = ruleset.select_random_blocks(RANDOM_DENSITY, rng)
		_:
			push_error("ROOMMATE: Unknown simple blocks selector type: %s." % simple_ruleset.blocks_selector)
	blocks_selector.set_offset(simple_ruleset.blocks_selector_offset)
	
	var parts_selector := ruleset.select_parts(simple_ruleset.selected_parts)
	parts_selector.inverse_selection = simple_ruleset.inverse_selection
	
	var transform := Transform3D.IDENTITY
	transform.origin = simple_ruleset.part_position_offset
	transform.basis = Basis.from_euler(simple_ruleset.part_rotation_offset)
	transform.scaled_local(simple_ruleset.part_scale_offset)
	parts_selector.mesh_transform.accumulate(transform)
	parts_selector.collision_transform.accumulate(transform)
	parts_selector.nav_transform.accumulate(transform)
	
	if simple_ruleset.mesh:
		parts_selector.mesh.override(simple_ruleset.mesh)
	if simple_ruleset.collision_mesh:
		parts_selector.collision_mesh.override(simple_ruleset.collision_mesh)
	if simple_ruleset.nav_mesh:
		parts_selector.nav_mesh.override(simple_ruleset.nav_mesh)
	if simple_ruleset.scene:
		parts_selector.scene.override(simple_ruleset.scene)
	
	if simple_ruleset.material:
		parts_selector.override_fallback_surface().material.override(simple_ruleset.material)
	
	if simple_ruleset.color != Color.WHITE:
		parts_selector.override_fallback_surface().set_color(simple_ruleset.color)
