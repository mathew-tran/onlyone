extends Panel

@onready var PawnImage = $HBoxContainer/VBoxContainer2/TextureRect
@onready var PawnNameText = $HBoxContainer/VBoxContainer2/Label
@onready var MovesLeftText = $HBoxContainer/VBoxContainer/Label
@onready var CanShootText = $HBoxContainer/VBoxContainer/Label2

func _ready() -> void:
	Helper.GetGame().OnPawnUpdate.connect(OnPawnUpdate)
	OnPawnUpdate()
	
func OnPawnUpdate():
	var pawn = Helper.GetGame().GetCurrentPawn() as Pawn
	PawnNameText.text =  pawn.CharData.Name
	PawnImage.texture = pawn.CharData.CharImage
	MovesLeftText.text = "Moves Left: " + str(pawn.MovesLeft) + "/" + str(pawn.CharData.Moves)
	CanShootText.text = "Can Attack: " +  str(pawn.bCanShoot)
	
