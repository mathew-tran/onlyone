extends Node2D

class_name Game

@export var CurrentPawn : Pawn

signal OnPawnUpdate
signal OnEndTurn
signal OnTurnStart(amount)
var TabIndex = -1
var Turns = 0


func _ready() -> void:
	for pawn in GetPawnList():
		pawn.Refresh()
	OnEndTurn.connect(EndTurn)
	
	EndTurn()
	OnTurnStart.emit(Turns)
	
func GetPawnList():
	if $PawnList:
		return $PawnList.get_children()
	return []

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tab"):
		#SwitchNextValidPawn()
		pass
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func SwitchNextValidPawn():
	TabIndex += 1
	if TabIndex >= len(GetPawnList()):
		TabIndex = 0
	
	if GetPawnList():
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
		Turns += 1
		$CanvasLayer/Label.text = "TURN " + str(Turns)
		OnTurnStart.emit(Turns)
		DecideNextPawn()
	
		
func EndTurn():
	DecideNextPawn()
	
func GetCurrentPawn():
	return CurrentPawn

func _process(delta: float) -> void:
	if GetCurrentPawn():
		$Camera2D.global_position = GetCurrentPawn().global_position


func _on_pawn_list_child_order_changed() -> void:
	if is_instance_valid($CanvasLayer) == false:
		return
	if len(GetPawnList()) == 1:
		$CanvasLayer/DeadEndPanel.visible = true
	else:
		$CanvasLayer/DeadEndPanel.visible = false
