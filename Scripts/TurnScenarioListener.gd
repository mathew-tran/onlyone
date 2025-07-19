@tool

extends ScenarioListener

# Used to spawn objects, move things around, or trigger talking
class_name TurnScenarioListener

@export var TurnNumber = 0
@export var Dialogue = ""

func GetUniqueName():
	return "TURN" + str(TurnNumber) + "-SPEAK"
	
func DoSetup():
	Helper.GetGame().OnTurnStart.connect(OnTurnStart)
	
func OnTurnStart(turn):
	if turn == TurnNumber:
		if is_instance_valid(Character):
			Character.Speak(Dialogue)
		Complete()
	
