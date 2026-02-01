extends Control

@onready var killerName = $PersonName
var selectedMonigote;

signal KillMonigote(node)
signal Cancel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setKillerName(monigote: Node2D) -> void:
	killerName.text = monigote.name;
	selectedMonigote = monigote
	print(monigote)


func _on_kill_button_down() -> void:
	KillMonigote.emit(selectedMonigote)


func _on_cancel_button_down() -> void:
	Cancel.emit()
