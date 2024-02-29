extends Node

class_name GameManager

func _ready() -> void:
	EventBus.exploding_drawn.connect(_on_exploding_drawn)

func start_game() -> void:
	pass

func _on_exploding_drawn(player: Player) -> void:
	print("Boom")
