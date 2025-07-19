@tool

extends Node2D

# Used to spawn objects, move things around, or trigger talking
class_name ScenarioListener
 
@export var Character : Pawn

func _ready() -> void:
	name = "SCEN-" + GetUniqueName()
	Setup()
	
func GetUniqueName():
	return "BLAH"
	
func DoSetup():
	pass
	
func Setup():
	if Engine.is_editor_hint():
		return
	DoSetup()
	
func Complete():
	if Engine.is_editor_hint():
		return
	queue_free()
