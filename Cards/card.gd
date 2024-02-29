class_name Card

extends Control

@export var card_stats: CardStats
@export var card_effect: CardEffect

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var draggable_component: Draggable = $Draggable
@onready var card_layout: Control = $CardLayout

var original_position := global_position
var original_rotation := rotation
var card_title: String
var hoverable: bool = false

const CARD_HOVER_Y_OFFSET: int = 40

signal card_hovered(card:Card)
signal card_unhovered(card:Card)
signal card_discarded(card:Card)

func draw() -> void:
	flip()
	card_layout.set_default_cursor_shape(Control.CURSOR_POINTING_HAND)

func set_original_card_state() -> void:
	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "global_position", original_position, 0.1)
	tween.tween_property(self, "rotation", original_rotation, 0.1)
	scale = Vector2(0.5, 0.5)
	
	z_index = 0

func update_positions() -> void:
	hoverable = true
	original_position = global_position
	original_rotation = rotation

func flip() -> void:
	animation_player.play("flip")

func _on_mouse_entered() -> void:
	if hoverable and not GlobalState.is_dragging:
		#Emitting so we can launch side effects like moving neighbouring cards
		card_hovered.emit(self)
		
		#Parent is always going to be the base Y offset where we need to modify the position
		#TODO 
		#Change it to be more cleaner later
		var hand: Node2D = get_parent()
		
		var new_position := Vector2(global_position.x, hand.global_position.y - CARD_HOVER_Y_OFFSET)
		var tween := get_tree().create_tween().set_parallel(true)
		tween.tween_property(self, "global_position", new_position, 0.1)
		tween.tween_property(self, "rotation", 0, 0.1)
		
		scale = Vector2(0.6, 0.6)
		z_index = 1
		draggable_component.on_mouse_entered(original_position)

func _on_mouse_exited() -> void:
	if hoverable and not GlobalState.is_dragging:
		card_unhovered.emit(self)
		set_original_card_state()
		draggable_component.on_mouse_exited()

func _on_draggable_draggable_released(is_inside_droppable: bool) -> void:
	if is_inside_droppable:
		card_effect.play(Player.new(), Player.new())
		card_discarded.emit(self)
		z_index = 0
	else:
		_on_mouse_exited()
