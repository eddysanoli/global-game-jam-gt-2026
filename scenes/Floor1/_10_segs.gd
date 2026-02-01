extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.is_visible_in_tree():
		hideSelf()

func showSelf() -> void:
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(self, "modulate:a", 1.0, 0)
	self.show()

func hideSelf() -> void:
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(self, "modulate:a", 0.0, 1.5)
	await tween.finished
	self.hide()
