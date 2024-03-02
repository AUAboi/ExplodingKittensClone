class_name CardState
extends State

var card: Card

func _ready() -> void:
	await owner.ready
	card = owner as Card
	assert(card != null)
