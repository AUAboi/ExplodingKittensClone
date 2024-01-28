extends VBoxContainer

@export var card: Card = owner

@onready var flavor_text_label: Label = %FlavorText
@onready var card_title_top: Label = %CardTitleTop
@onready var card_title_bottom: Label = %CardTitleBottom

func _ready() -> void:
	card_title_top.text = card.card_title
	card_title_bottom.text = card.card_title
	if card.card_stats != null:
		flavor_text_label.text = card.card_stats.flavor_text

