extends Node2D

class_name CardManager

var base_card_scene: PackedScene = preload("res://Cards/base_card.tscn")
var deck_list: Array[Card]
var player_hand: Array[Card]

@export var hand: Node2D
@export var deck: Node2D

const ANGLE_CURVE = preload("res://UI/Resources/angle_curve.tres") as Curve
const SPREAD_CURVE = preload("res://UI/Resources/spread_curve.tres") as Curve
const HEIGHT_CURVE = preload("res://UI/Resources/height_curve.tres") as Curve

const CARD_SIZE := Vector2(125, 175)
const SCREEN_EDGE_BORDER = 125.0
const MAX_DIST_BETWEEN_HAND_CARDS = 235.0 / 2

func _ready() -> void:
	_create_deck()
	deck_list.shuffle()
	for card in deck_list:
		deck.add_child(card)
		card.scale = Vector2(0.35, 0.35)

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
	
	deck_list.append(card)

func _deck_ratio_calc(card:Card) -> float:
	var deck_ratio := 0.50
	if hand.get_child_count() > 1:
		deck_ratio = float(card.get_index()) / float(hand.get_child_count() - 1.0)

	return deck_ratio

func draw_card() -> void:
	if deck_list.size() > 0:
		var card: Card = deck_list.pop_back()
		card.flip()
		
		card.card_hovered.connect(_on_card_hover)
		card.card_unhovered.connect(_on_card_unhovered)
		
		player_hand.append(card)
		card.reparent(hand)
		
		_update_hand_position()

func _update_hand_position() -> void:
	var current_hand_size = player_hand.size()
	var viewport_size = get_viewport_rect().size
	var horizontal_space = viewport_size.x  - SCREEN_EDGE_BORDER - SCREEN_EDGE_BORDER - CARD_SIZE.x
	var dist_between_cards = min(horizontal_space / current_hand_size, MAX_DIST_BETWEEN_HAND_CARDS * 2)
	var card_x = ((viewport_size.x + (dist_between_cards * (current_hand_size))) * 0.5) - (dist_between_cards * 0.5)

	var separation = 0.3
	if current_hand_size <= 3:
		separation = 0.1
	if current_hand_size >= 4 && current_hand_size <= 6:
		separation = 0.2

	for card in hand.get_children():
		card.hoverable = false
		
		var destination := hand.global_position
		var hand_ratio = _deck_ratio_calc(card)
		
		destination.x += card_x * SPREAD_CURVE.sample(hand_ratio) * separation
		destination.y += HEIGHT_CURVE.sample(hand_ratio) * -1 * 20
		
		var target_rotation = ANGLE_CURVE.sample(hand_ratio) * 0.1
		
		card.rotation = -target_rotation
		
		var tween = get_tree().create_tween().set_parallel(true)  

		tween.tween_property(card, "global_position", destination, 0.5)
		tween.tween_property(card, "rotation", -target_rotation, 0.5)
		tween.tween_property(card, "scale", Vector2(0.5, 0.5), 0.5)
		
		tween.connect("finished", _on_tween_finished.bind(card))

func _on_tween_finished(card: Card)->void:
	card.update_positions() 

func _on_card_hover(card: Card) -> void:
	var card_index := card.get_index()
	var card_before_index := card_index - 1
	var card_after_index := card_index + 1
	var cards_in_hand := hand.get_children()
	
	
	if card_before_index >= 0:
		var tilt_left_position: Vector2 = cards_in_hand[card_before_index].original_position
		var tween_left = get_tree().create_tween()
	
		tilt_left_position.x -= 20
		tween_left.tween_property(cards_in_hand[card_before_index], "global_position", tilt_left_position, 0.1)
	
	if card_after_index <= hand.get_child_count() - 1:
		var tween_right = get_tree().create_tween()
		var tilt_right_position: Vector2 = cards_in_hand[card_after_index].original_position
		tilt_right_position.x += 20
		tween_right.tween_property(cards_in_hand[card_after_index], "global_position", tilt_right_position, 0.1)

func _on_card_unhovered(card: Card) -> void:
	var card_index := card.get_index()
	var card_before_index := card_index - 1
	var card_after_index := card_index + 1
	var cards_in_hand := hand.get_children()
	
	if card_before_index >= 0:
		cards_in_hand[card_before_index].set_original_card_state()
	
	if card_after_index <= hand.get_child_count() - 1:
		cards_in_hand[card_after_index].set_original_card_state()

