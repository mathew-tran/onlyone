extends Panel

func _enter_tree() -> void:
	visible = false
	
func Speak(words, time = 1):
	$Label.text = words
	visible = true
	await get_tree().create_timer(time).timeout
	visible = false
