class_name Card

extends Area2D

@export var card_stats: CardStats

@onready var flavor_text_label: Label = %FlavorText
@onready var card_title_top: Label = %CardTitleTop
@onready var card_title_bottom: Label = %CardTitleBottom
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var original_position := global_position
var original_rotation := rotation
var card_title: String
var hoverable: bool = false

signal card_hovered(card:Card)
signal card_unhovered(card:Card)

func _ready() -> void:
	if card_stats != null:
		card_title = _get_card_title()
		card_title_top.text = card_title
		card_title_bottom.text = card_title
		flavor_text_label.text = card_stats.flavor_text

func _get_card_title() -> String:
	match card_stats.type:
		Constants.CardTypes.EXPLODING_KITTEN:
			return "Exploding Kitten"
		Constants.CardTypes.DEFUSE:
			return "Defuse"
	
	return "NULL TYPE"

func _on_control_mouse_entered() -> void:
	if hoverable:
		card_hovered.emit(self)
		var new_position = global_position - Vector2(0, 20)
		
		var tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(self, "global_position", new_position, 0.1)
		tween.tween_property(self, "rotation", 0, 0.1)
		tween.tween_property(self, "scale", Vector2(0.6, 0.6), 0.1)
		z_index = 1

func _on_control_mouse_exited() -> void:
	if hoverable:
		card_unhovered.emit(self)
		set_original_card_state()

func set_original_card_state():
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "global_position", original_position, 0.1)
	tween.tween_property(self, "rotation", original_rotation, 0.1)
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.1)
	z_index = 0

func update_positions():
	hoverable = true
	original_position = global_position
	original_rotation = rotation

func flip() -> void:
	animation_player.play("flip")
