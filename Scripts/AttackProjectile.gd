extends Area2D

class_name Projectile

var TargetPosition = Vector2.ZERO
var Speed = 10
var Progress = 0
var InitialPosition = Vector2.ZERO

signal OnComplete

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	Progress += delta * Speed
	global_position = lerp(InitialPosition, TargetPosition, Progress)
	
	if Progress >= 1:
		
		set_process(false)
		force_update_transform()
		await get_tree().create_timer(.1).timeout
		var areas = get_overlapping_areas()
		for area in areas:
			if area is Pawn:
				await area.Kill()
		OnComplete.emit()
		queue_free()
