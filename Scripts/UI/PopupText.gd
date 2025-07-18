extends Node2D

func _enter_tree() -> void:
	$Label.visible = false
	
func Setup(data):	
	if data.has("text"):		
		$Label.text = data["text"]
		$Label.visible = true
	var timeToLive = .5
	if data.has("ttl"):
		timeToLive = data["ttl"]
	
	await get_tree().create_timer(timeToLive).timeout
	queue_free()
