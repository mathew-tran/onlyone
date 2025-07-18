extends Node2D

class_name Game

@export var CurrentPawn : Pawn

signal OnPawnUpdate
signal OnEndTurn

var TabIndex = -1
func _ready() -> void:
	for pawn in GetPawnList():
		pawn.Refresh()
	OnEndTurn.connect(EndTurn)
	EndTurn()
	
func GetPawnList():
	return $PawnList.get_children()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tab"):
		SwitchNextValidPawn()

func SwitchNextValidPawn():
	TabIndex += 1
	if TabIndex >= len(GetPawnList()):
		TabIndex = 0
	
	if GetPawnList()[TabIndex].IsAvailable():
		CurrentPawn.StallTurn()
		CurrentPawn = GetPawnList()[TabIndex]
		CurrentPawn.StartTurn()
			
func DecideNextPawn():
	var nextPawn : Pawn
	if len(GetPawnList()) <= 0:
		print("ALL PAWNS ARE DEAD")
		return
	for pawn in GetPawnList():
		if pawn.IsAvailable():
			nextPawn = pawn
	if nextPawn:
		nextPawn.StartTurn()
		CurrentPawn = nextPawn
		TabIndex = CurrentPawn.get_index()
		OnPawnUpdate.emit()
	else:
		for pawn in GetPawnList():
			pawn.Refresh()
		DecideNextPawn()
	
		
func EndTurn():
	DecideNextPawn()
	
func GetCurrentPawn():
	return CurrentPawn

func _process(delta: float) -> void:
	if GetCurrentPawn():
		$Camera2D.global_position = GetCurrentPawn().global_position


func _on_pawn_list_child_order_changed() -> void:
	if len(GetPawnList()) == 1:
		print("YOU WIN!")
