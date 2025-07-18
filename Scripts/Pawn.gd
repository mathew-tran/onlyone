extends Area2D

class_name Pawn

enum MOVE_TEST_RESULT {
	OTHER_PAWN,
	INVALID,
	OPEN_SPOT
}

enum DIRECTION {
	LEFT,
	RIGHT,
	UP,
	DOWN
}
var bCanMove = true
var bCanShoot = true

enum PAWN_STATE {
	TO_BE_USED,
	USING,
	TIRED
}

var CurrentState = PAWN_STATE.TO_BE_USED
var CurrentDirection = DIRECTION.RIGHT

var MovesLeft = 3

signal OnCharacterUpdate(pawn)

@export var CharData : CharacterData

func IsTired():
	return CurrentState == PAWN_STATE.TIRED
	
func IsBeingUsed():
	return CurrentState == PAWN_STATE.USING
	
func IsAvailable():
	return CurrentState == PAWN_STATE.TO_BE_USED
	
func UpdateState(newState):
	CurrentState = newState
	UpdateSprite()
	
func Refresh():
	MovesLeft = CharData.Moves
	bCanShoot = true
	UpdateState(PAWN_STATE.TO_BE_USED)
	set_process(false)
	modulate = Color.ANTIQUE_WHITE
	
func StartTurn():
	
	Helper.GetGame().OnPawnUpdate.emit()
	UpdateState(PAWN_STATE.USING)
	print(name + " TURN START")
	set_process(true)
	modulate = Color.WHITE
	
func StallTurn():
	UpdateState(PAWN_STATE.TO_BE_USED)
	modulate = Color.PINK
	set_process(false)
	
func EndTurn():
	print(name + " TURN END")
	
	UpdateState(PAWN_STATE.TIRED)
	Helper.GetGame().OnEndTurn.emit()
	set_process(false)
	modulate = Color.DARK_GRAY
	
	
func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if CurrentState != PAWN_STATE.USING:
		return
	
	if MovesLeft <= 0 and bCanShoot == false:
		EndTurn()
		return
	if Input.is_action_just_pressed("end_turn"):
		EndTurn()
		return
	
	if Input.is_action_just_pressed("attack"):
		if bCanShoot:
			bCanShoot = false
			MovesLeft = 0
			print(name + "shoot")
			Helper.GetGame().OnPawnUpdate.emit()
		return
		
	if CanMove() == false:
		return
		

		
	var moveVector = Vector2.ZERO
	if Input.is_action_just_pressed("left"):
		moveVector.x = -1
		CurrentDirection = DIRECTION.LEFT
		
	elif Input.is_action_just_pressed("right"):
		moveVector.x += 1
		CurrentDirection = DIRECTION.RIGHT
		
	elif Input.is_action_just_pressed("up"):
		moveVector.y -= 1
		CurrentDirection = DIRECTION.UP
	
	elif Input.is_action_just_pressed("down"):
		moveVector.y += 1
		CurrentDirection = DIRECTION.DOWN
		
	if moveVector != Vector2.ZERO:
		bCanMove = false
		$TestMoveShape.position = moveVector * Definitions.CellSize
		print("test position" + str($TestMoveShape.global_position))
		
		$TestMoveShape.force_update_transform()
		await get_tree().create_timer(.1).timeout
		
		var areas = $TestMoveShape.get_overlapping_areas()
		
		var result = CheckResult(areas)
		
		match result:
			MOVE_TEST_RESULT.OPEN_SPOT:
				global_position += moveVector * Definitions.CellSize
		bCanMove = true
		MovesLeft -= 1
		Helper.GetGame().OnPawnUpdate.emit()
		UpdateSprite()

func CanMove():
	return MovesLeft > 0 and bCanMove 
	
func CheckResult(areas):
	print(areas)
	if len(areas) <= 0:
		return MOVE_TEST_RESULT.INVALID
	
	for area in areas:		
		if area is Pawn:
			if area != self:
				return MOVE_TEST_RESULT.OTHER_PAWN
	return MOVE_TEST_RESULT.OPEN_SPOT
	

func UpdateSprite():
	match CurrentDirection:
		DIRECTION.LEFT:
			$TextureRect.rotation_degrees = 180
		DIRECTION.UP:
			$TextureRect.rotation_degrees = 270
		DIRECTION.RIGHT:
			$TextureRect.rotation_degrees = 0
		DIRECTION.DOWN:
			$TextureRect.rotation_degrees = 90
	if CurrentState == PAWN_STATE.USING:
		$Higlight.visible = true
	else:
		$Higlight.visible = false
	
	if CurrentState == PAWN_STATE.TIRED:
		$TiredHighlight.visible = true
	else:
		$TiredHighlight.visible = false
		
