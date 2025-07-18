extends Area2D

class_name Tile

@export var bIsWalkable = true
@export var bBreakable = false

func ReplaceTile():
	var regularTile = load("res://Prefabs/Tile.tscn").instantiate()		
	get_parent().add_child(regularTile)
	regularTile.global_position = global_position
	queue_free()
