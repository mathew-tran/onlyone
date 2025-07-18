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

var CurrentDirection = DIRECTION.RIGHT

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if bCanMove == false:
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
		UpdateSprite()

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
