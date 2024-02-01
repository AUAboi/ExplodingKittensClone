extends Control

@onready var card_manager: Node2D = $CardManager


func _ready() -> void:
	pass
		
func _on_button_pressed() -> void:
	card_manager.draw_card()
