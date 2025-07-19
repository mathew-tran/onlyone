@tool

extends ObjectiveListener

class_name KillObjectiveListener

@export var Character : Pawn

func GetUniqueName():
	return "KILL-" + Character.CharData.Name + "-LEVEL-CHANGE"
	
func DoSetup():
	Character.OnDeath.connect(Complete)
