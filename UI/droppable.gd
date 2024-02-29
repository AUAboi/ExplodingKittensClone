extends StaticBody2D

class_name Droppable

func _ready() -> void:
	#TODO
	#Make this modular
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)

func _process(_delta: float) -> void:
	visible = GlobalState.is_dragging
