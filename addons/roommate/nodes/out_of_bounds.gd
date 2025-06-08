# Copyright (c) 2025 Kirill Rozhkov.
#
# This file is part of Roommate plugin: https://github.com/Hoork/Roommate
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

@tool
class_name RoommateOutOfBounds
extends RoommateBlocksArea


func _process_block(new_block: RoommateBlock) -> RoommateBlock:
	new_block.type_id = "btid_out_of_bounds";
	return new_block
