# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateBlocksSelector
extends Resource


func select(source_blocks: RoommateBlocksArea.Blocks) -> RoommateBlocksArea.Blocks:
	var blocks := RoommateBlocksArea.Blocks.new()
	blocks.merge(source_blocks)
	return blocks
