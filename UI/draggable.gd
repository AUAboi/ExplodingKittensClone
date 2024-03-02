extends Area2D

class_name Draggable

@export var actor: Node

var draggable := false
var is_inside_droppable := false
var offset: Vector2

var start_position: Vector2

signal draggable_released(is_inside_droppable: bool)

func _process(_delta: float) -> void:
	if draggable:
		if Input.is_action_just_pressed("click"):
			offset = get_global_mouse_position() - global_position
			GlobalState.is_dragging = true
			
		if Input.is_action_pressed("click"):
			actor.global_position = get_global_mouse_position() - offset
			
		elif Input.is_action_just_released("click"):
			GlobalState.is_dragging = false
			draggable = false
			draggable_released.emit(is_inside_droppable)

func on_mouse_entered(start_pos: Vector2) -> void:
	if not GlobalState.is_dragging:
		start_position = start_pos
		draggable = true

func on_mouse_exited() -> void:
	if not GlobalState.is_dragging:
		draggable = false

func _on_body_entered(body: Node2D) -> void:
	is_inside_droppable = true
	body.modulate = Color(Color.REBECCA_PURPLE, 1)

func _on_body_exited(body: Node2D) -> void:
	is_inside_droppable = false
	body.modulate = Color(Color.REBECCA_PURPLE, 0.7)
