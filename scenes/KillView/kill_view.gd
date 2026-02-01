extends Control

@onready var killerName = $PersonName
var selectedMonigote;
var people
var mask

signal KillMonigote(node)
signal Cancel



func setKillerName(monigote: Node2D) -> void:
	killerName.text = " vampire?\n Is this a";
	selectedMonigote = monigote
	print(monigote)


func _on_kill_button_down() -> void:
	KillMonigote.emit(selectedMonigote)


func _on_cancel_button_down() -> void:
	Cancel.emit()
