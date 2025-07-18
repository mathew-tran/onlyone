@tool

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
	UpdateState(PAWN_STATE.USING)
	print(name + " TURN START")
	set_process(true)
	modulate = Color.WHITE
	Helper.GetGame().OnPawnUpdate.emit()
	var data = {}
	data["text"] = "Turn Started"
	Helper.CreateText(data, global_position)
	
func StallTurn():
	UpdateState(PAWN_STATE.TO_BE_USED)
	modulate = Color.PINK
	set_process(false)
	
func EndTurn():
	print(name + " TURN END")
	var data = {}
	data["text"] = "Turn Ended"
	Helper.CreateText(data, global_position)
	
	UpdateState(PAWN_STATE.TIRED)
	Helper.GetGame().OnEndTurn.emit()
	set_process(false)
	modulate = Color.DARK_GRAY
	
	
func _ready() -> void:
	$TextureRect.texture = CharData.CharImage
	CreateAttackPreviewHighlight()

func CreateAttackPreviewHighlight():
	for child in $AttackHighlightPreview.get_children():
		child.queue_free()
		
	var highlightClass = load("res://Prefabs/UI/AttackPreviewHighlight.tscn")
	
	for pos in GetAttackPositions():
		var instance = highlightClass.instantiate()

		$AttackHighlightPreview.add_child(instance)
		instance.global_position = pos
		
func _process(delta: float) -> void:
	var nextDirection = CurrentDirection
	if Engine.is_editor_hint():
		return
		
	if CurrentState != PAWN_STATE.USING:
		return
	
	if bCanMove == false:
		return
		
	if MovesLeft <= 0 and bCanShoot == false:
		EndTurn()
		return
		
	if Input.is_action_just_pressed("end_turn"):
		EndTurn()
		return
	
	if Input.is_action_just_pressed("attack"):
		if bCanShoot:
			set_process(false)
			bCanShoot = false
			MovesLeft = 0
			print(name + "shoot")
			await Shoot()
			Helper.GetGame().OnPawnUpdate.emit()
			set_process(true)
		else:
			var data = {}
			data["text"] = "No attacks left"
			Helper.CreateText(data, global_position)
		return
		


		
	var moveVector = Vector2.ZERO
	if Input.is_action_just_pressed("left"):
		moveVector.x = -1
		nextDirection = DIRECTION.LEFT
		
	elif Input.is_action_just_pressed("right"):
		moveVector.x += 1
		nextDirection = DIRECTION.RIGHT
		
	elif Input.is_action_just_pressed("up"):
		moveVector.y -= 1
		nextDirection = DIRECTION.UP
	
	elif Input.is_action_just_pressed("down"):
		moveVector.y += 1
		nextDirection = DIRECTION.DOWN
		
	if moveVector != Vector2.ZERO:
		
		if CanMove() == false:
			var data = {}
			data["text"] = "No moves left"
			Helper.CreateText(data, global_position)
			return
		
		CurrentDirection = nextDirection
		bCanMove = false
		$TestMoveShape.position = moveVector * Definitions.CellSize
		print("test position" + str($TestMoveShape.global_position))
		
		$TestMoveShape.force_update_transform()
		await get_tree().create_timer(.1).timeout
		
		var areas = $TestMoveShape.get_overlapping_areas()
		
		var result = CheckResult(areas)
		
		UpdateSprite()
		match result:
			MOVE_TEST_RESULT.OPEN_SPOT:
				var tween = get_tree().create_tween()
				tween.tween_property(self, "scale", Vector2.ONE * .8, .01)
				tween.tween_property(self, "global_position", global_position + moveVector * Definitions.CellSize, .05)
				
				await tween.finished
				tween = get_tree().create_tween()
				tween.tween_property(self, "scale", Vector2.ONE, .05)
				await tween.finished
		bCanMove = true
		UpdateSprite()
		MovesLeft -= 1
		Helper.GetGame().OnPawnUpdate.emit()
		

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
		if area is Tile:
			if area.bIsWalkable == false:
				return MOVE_TEST_RESULT.INVALID
	return MOVE_TEST_RESULT.OPEN_SPOT
	
func GetAttackPositions():
	var positions = []
	var snappedParam = Definitions.CellSize.x
	for pos in CharData.AttackPositions:
		var rot = 0
		var currentPos = global_position
		match CurrentDirection:
			DIRECTION.LEFT:
				rot = 90
			DIRECTION.UP:
				rot = 180
			DIRECTION.RIGHT:
				rot = 270
			DIRECTION.DOWN:
				rot = 0
		var targetPosition = Vector2(pos.x, pos.y).rotated(deg_to_rad(rot))
		
		currentPos += targetPosition * Definitions.CellSize

		currentPos = Vector2(snappedi(currentPos.x, snappedParam), 
		snappedi(currentPos.y, snappedParam))
		positions.append(currentPos)
	return positions
	
func Shoot():
	for pos in GetAttackPositions():
		var projClass = load("res://Prefabs/Attacks/AttackProjectile.tscn")
		var instance = projClass.instantiate() as Projectile
		instance.global_position = global_position
		instance.InitialPosition = global_position
		instance.TargetPosition = pos
		Helper.GetEffectsGroup().add_child(instance)
		await instance.OnComplete
	
func GetForwardVector():
	match CurrentDirection:
		DIRECTION.LEFT:
			return Vector2.LEFT
		DIRECTION.UP:
			return Vector2.UP
		DIRECTION.RIGHT:
			return Vector2.RIGHT
		DIRECTION.DOWN:
			return Vector2.DOWN
			
func UpdateSprite():
	var targetRotation = 0
	match CurrentDirection:
		DIRECTION.LEFT:
			targetRotation = 180
		DIRECTION.UP:
			targetRotation = 270
		DIRECTION.RIGHT:
			targetRotation = 0
		DIRECTION.DOWN:
			targetRotation = 90
			
	var tween = get_tree().create_tween()
	tween.tween_property($TextureRect, "rotation_degrees", targetRotation, .1)
	if CurrentState == PAWN_STATE.USING and bCanMove:
		CreateAttackPreviewHighlight()
		$Higlight.visible = true
		$AttackHighlightPreview.visible = true
	else:
		$Higlight.visible = false
		$AttackHighlightPreview.visible = false
	
	if CurrentState == PAWN_STATE.TIRED:
		$TiredHighlight.visible = true
	else:
		$TiredHighlight.visible = false
		
func Kill():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, .3)
	await tween.finished
	
	queue_free()
