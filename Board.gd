extends Control

var base_card_scene: PackedScene = preload("res://Cards/base_card.tscn")
var deck: Array[Card]
var player_hand: Array[Card]

@onready var hand: Node2D = $Hand
@onready var deck_box: Node2D = $Deck

const ANGLE_CURVE = preload("res://UI/Resources/angle_curve.tres") as Curve
const SPREAD_CURVE = preload("res://UI/Resources/spread_curve.tres") as Curve
const HEIGHT_CURVE = preload("res://UI/Resources/height_curve.tres") as Curve

const CARD_SIZE := Vector2(125, 175)
const SCREEN_EDGE_BORDER = 125.0
const MAX_DIST_BETWEEN_HAND_CARDS = 235.0 / 2
var separation := 1.0/deck.size()
var offset = 0
var rotate_offset = -10.5

func _ready() -> void:
	_create_deck()
	for card in deck:
		deck_box.add_child(card)

func _create_deck() -> void:
	var path = "res://Cards/Defuse/Resources/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				_load_card(path + file_name, base_card_scene)
				
			file_name = dir.get_next()

func _load_card(path: String, scene: PackedScene) -> void:
	var card: Card = scene.instantiate() as Card
	card.card_stats = load(path)
	deck.append(card)
	
	var card_again: Card = scene.instantiate() as Card
	card_again.card_stats = load(path)
	deck.append(card_again)

func deck_ratio_calc(card:Card) -> float:
	var deck_ratio := 0.50
	if hand.get_child_count() > 1:
		deck_ratio = float(card.get_index()) / float(hand.get_child_count() - 1.0)

	return deck_ratio

func draw_hand():
	print("\n")
	var separation = 42.5 * hand.get_child_count()
	var max = get_viewport_rect().size - CARD_SIZE
	
	for card in hand.get_children():
		var hand_ratio = deck_ratio_calc(card)
		var destination := hand.global_position
		
		destination.x += SPREAD_CURVE.sample(hand_ratio)  * separation
		
		card.global_position = destination 


func draw_card():
	if deck.size() > 0:
		var card: Card = deck.pick_random()
		deck.erase(card)
		player_hand.append(card)
		card.reparent(hand)
		update_hand_position()

func my_draw_card():
	if deck.size() > 0:
		var card: Card = deck.pick_random()
		deck.erase(card)
		card.reparent(hand)
		var curve = SPREAD_CURVE.sample(deck_ratio_calc(card))
		
		var tween = get_tree().create_tween()
		tween.tween_property(card, "rotation", deg_to_rad(rotate_offset), 0.5)
		tween.tween_property(card, "position", Vector2(0 + offset, -70), 0.5)
		
		offset += 125
		rotate_offset += 5.5

func update_hand_position():
	var current_hand_size = player_hand.size()
	var viewport_size = get_viewport_rect().size
	var horizontal_space = viewport_size.x  - SCREEN_EDGE_BORDER - SCREEN_EDGE_BORDER - CARD_SIZE.x
	var dist_between_cards = min(horizontal_space / current_hand_size, MAX_DIST_BETWEEN_HAND_CARDS * 2)
	var card_x = ((viewport_size.x + (dist_between_cards * (current_hand_size))) * 0.5) - (dist_between_cards * 0.5)

	var separation = 0.5
	if current_hand_size <= 2:
		separation = 0.1
	if current_hand_size >= 3 && current_hand_size <= 5:
		separation = 0.3

	for card in hand.get_children():
		var half_viewport_x = viewport_size.x * 0.5 
		var destination := hand.global_position
		var hand_ratio = deck_ratio_calc(card)
		
		destination.x += card_x * SPREAD_CURVE.sample(hand_ratio) * separation
		destination.y += HEIGHT_CURVE.sample(hand_ratio) * -1 * 20
		
		var target_rotation = ANGLE_CURVE.sample(hand_ratio) * 0.1
		
		card.rotation = -target_rotation
		
		var tween = get_tree().create_tween()
		tween.tween_property(card, "global_position", destination, 0.5)
		tween.tween_property(card, "rotation", -target_rotation, 0.5)
		
func _on_button_pressed() -> void:
	draw_card()
