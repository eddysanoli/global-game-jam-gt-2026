class_name Monigote extends CharacterBody2D

signal monigoteClicked(node)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		monigoteClicked.emit(self)
