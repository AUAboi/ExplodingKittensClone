extends Control

@onready var card_manager: Node2D = $CardManager


func _ready() -> void:
	pass


func _on_button_pressed() -> void:
	card_manager.draw_card()

func _on_deck_input_event(_viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				card_manager.draw_card()
