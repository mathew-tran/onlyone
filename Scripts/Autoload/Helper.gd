extends Node

func GetGame() -> Game:
	return get_tree().get_nodes_in_group("Game")[0]

func GetEffectsGroup():
	return get_tree().get_nodes_in_group("Effects")[0]

func CreateText(data, textPosition):
	var textClass = load("res://Prefabs/UI/PopupText.tscn")
	var instance = textClass.instantiate()
	
	GetEffectsGroup().add_child(instance)
	instance.global_position = textPosition
	instance.Setup(data)
