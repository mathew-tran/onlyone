@tool

extends Node

class_name ObjectiveListener

@export_file("*.tscn") var PlaceToGoTo

func _ready() -> void:
	name = "OBJ-LIST-"  + GetUniqueName()
	Setup()
	
func GetUniqueName():
	return "blah"
	
func DoSetup():
	pass
	
func Setup():
	if Engine.is_editor_hint():
		return
	DoSetup()
	
func Complete():
	if Engine.is_editor_hint():
		return
	if PlaceToGoTo != null:
		get_tree().change_scene_to_file(PlaceToGoTo)
