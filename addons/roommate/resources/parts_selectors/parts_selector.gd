@tool
class_name RoommatePartsSelector
extends Resource


func select(selected_parts: Array[RoommatePart], source_parts: Array[RoommatePart]) -> Array[RoommatePart]:
	return selected_parts.duplicate()
