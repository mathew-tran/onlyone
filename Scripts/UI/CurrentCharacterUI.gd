extends Panel

@onready var PawnImage = $HBoxContainer/VBoxContainer2/TextureRect
@onready var PawnNameText = $HBoxContainer/VBoxContainer2/Label
@onready var MovesLeftText = $HBoxContainer/VBoxContainer/Label
@onready var CanShootText = $HBoxContainer/VBoxContainer/Label2
@onready var AttackDescription = $HBoxContainer/VBoxContainer/AttackDescription
func _ready() -> void:
	Helper.GetGame().OnPawnUpdate.connect(OnPawnUpdate)
	OnPawnUpdate()
	
func OnPawnUpdate():
	get_tree().create_timer(.1).timeout
	var pawn = Helper.GetGame().GetCurrentPawn() as Pawn
	if pawn == null:
		visible = false
		return
		
	visible = true
	PawnNameText.text =  pawn.CharData.Name
	PawnImage.texture = pawn.CharData.CharImage
	MovesLeftText.text = "Moves Left: " + str(pawn.MovesLeft) + "/" + str(pawn.CharData.Moves)
	AttackDescription.text = pawn.CharData.AttackDescription
	CanShootText.text = "Can Attack: " +  str(pawn.bCanShoot)
	
