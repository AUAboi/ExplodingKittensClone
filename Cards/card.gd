class_name Card

extends Area2D

@export var card_stats: CardStats
@export var card_title: String

@onready var flavor_text_label: Label = %FlavorText
@onready var card_title_top: Label = %CardTitleTop
@onready var card_title_bottom: Label = %CardTitleBottom

func _ready() -> void:
	if card_stats != null:
		card_title_top.text = card_title
		card_title_bottom.text = card_title
		flavor_text_label.text = card_stats.flavor_text
 
