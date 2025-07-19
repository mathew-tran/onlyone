extends Node

func GetGame() -> Game:
	var result = get_tree().get_nodes_in_group("Game")
	if result:
		return result[0]
	return null

func GetEffectsGroup():
	var result = get_tree().get_nodes_in_group("Effects")
	if result:
		return result[0]
	return null

func CreateText(data, textPosition):
	var textClass = load("res://Prefabs/UI/PopupText.tscn")
	var instance = textClass.instantiate()
	
	GetEffectsGroup().add_child(instance)
	instance.global_position = textPosition
	instance.Setup(data)
