extends Control

class_name CardLayout

@export var actor: Card

@onready var flavor_text_label: Label = %FlavorText
@onready var card_title_top: Label = %CardTitleTop
@onready var card_title_bottom: Label = %CardTitleBottom
@onready var panel: Panel = $Panel


func _ready() -> void:
	#Card layout will always belong to Card
	actor = owner as Card
	
	var card_title := _get_card_title()
	card_title_top.text = card_title
	card_title_bottom.text = card_title
	flavor_text_label.text = actor.card_stats.flavor_text
	
	set_card_styles()


func _get_card_title() -> String:
	match actor.card_stats.type:
		Constants.CardTypes.EXPLODING_KITTEN:
			return "Exploding Kitten"
		Constants.CardTypes.DEFUSE:
			return "Defuse"
	
	return "NULL TYPE"

func _get_card_color() -> Color:
	match actor.card_stats.type:
		Constants.CardTypes.EXPLODING_KITTEN:
			return Color.BLACK
		Constants.CardTypes.DEFUSE:
			return Color(47/255.0, 216/255.0, 126/255.0)
		
	return Color.BLACK

func set_card_styles() -> void:
	var card_type: String = Constants.CardTypes.keys()[actor.card_stats.type]
	var stylebox: StyleBoxFlat = panel.get_theme_stylebox("panel")
	stylebox.bg_color = _get_card_color()
	panel.add_theme_stylebox_override("panel", stylebox)
