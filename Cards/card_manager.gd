extends Node2D

class_name CardManager

var base_card_scene: PackedScene = preload("res://Cards/base_card.tscn")
var deck_list: Array[Card]
var player_hand_list: Array[Card]

@export var player_hand: Node2D
@export var enemy_hand: Node2D

@export var deck: Node2D
@export var discard_pile: Control

const ANGLE_CURVE = preload("res://UI/Resources/angle_curve.tres") as Curve
const SPREAD_CURVE = preload("res://UI/Resources/spread_curve.tres") as Curve
const HEIGHT_CURVE = preload("res://UI/Resources/height_curve.tres") as Curve

const CARD_SIZE := Vector2(125, 175)
const SCREEN_EDGE_BORDER = 125.0
const MAX_DIST_BETWEEN_HAND_CARDS = 235.0 / 2

const CARD_HOVER_X_OFFSET: int = 20



func _ready() -> void:
	_create_deck()
	deck_list.shuffle()
	for card in deck_list:
		deck.add_child(card)
		card.scale = Vector2(0.35, 0.35)

func _create_deck() -> void:
	var path := "res://Cards/Defuse/Resources/"
	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				_load_card(path + file_name, base_card_scene)
				
			file_name = dir.get_next()

func _load_card(path: String, scene: PackedScene) -> void:
	var card: Card = scene.instantiate() as Card
	card.card_stats = load(path)
	_load_card_effect(card)
	deck_list.append(card)

func _load_card_effect(card: Card) -> void:
	#Load every card's effect and do required assignments :/
	#TODO:
	#Make this better somehow and prevent individual loading
	#And PLEASE CLEAN THIS UP WITH :peace: and :love:
	var card_type: String = Constants.CardTypes.keys()[card.card_stats.type]
	var effect_path: String = "res://Cards/" + card_type.to_lower().capitalize() + "/" + card_type.to_lower() + "_effect.gd"
	
	if ResourceLoader.exists(effect_path):
		var effect: Resource = load(effect_path)
		var effect_scene: CardEffect = effect.new()
		card.add_child(effect_scene)
		effect_scene.actor = card
		card.card_effect = effect_scene

func _deck_ratio_calc(card:Card) -> float:
	var deck_ratio := 0.50
	if player_hand.get_child_count() > 1:
		deck_ratio = float(card.get_index()) / float(player_hand.get_child_count() - 1.0)
	
	return deck_ratio

func draw_card() -> void:
	if deck_list.size() > 0:
		var card: Card = deck_list.pop_back()
		card.card_hovered.connect(_on_card_hover)
		card.card_unhovered.connect(_on_card_unhovered)
		card.card_discarded.connect(_on_card_discarded)
		player_hand_list.append(card)
		card.reparent(player_hand)
		_update_hand_position()
		card.draw()

func _update_hand_position() -> void:
	var current_hand_size := player_hand_list.size()
	var viewport_size := get_viewport_rect().size
	var horizontal_space := viewport_size.x  - SCREEN_EDGE_BORDER - SCREEN_EDGE_BORDER - CARD_SIZE.x
	var dist_between_cards: float = min(horizontal_space / current_hand_size, MAX_DIST_BETWEEN_HAND_CARDS * 2)
	var card_x := ((viewport_size.x + (dist_between_cards * (current_hand_size))) * 0.5) - (dist_between_cards * 0.5)

	var separation := 0.3
	if current_hand_size <= 3:
		separation = 0.1
	if current_hand_size >= 4 && current_hand_size <= 6:
		separation = 0.2

	for card in player_hand.get_children():
		card.hoverable = false
		
		var destination := player_hand.global_position
		var hand_ratio := _deck_ratio_calc(card)
		
		destination.x += card_x * SPREAD_CURVE.sample(hand_ratio) * separation
		destination.y += HEIGHT_CURVE.sample(hand_ratio) * -1 * 20
		
		var target_rotation := ANGLE_CURVE.sample(hand_ratio) * 0.1
		
		card.rotation = -target_rotation
		
		var tween := get_tree().create_tween().set_parallel(true)  

		tween.tween_property(card, "global_position", destination, 0.5)
		tween.tween_property(card, "rotation", -target_rotation, 0.5)
		tween.tween_property(card, "scale", Vector2(0.5, 0.5), 0.5)
		
		tween.connect("finished", _on_tween_finished.bind(card))

func _on_tween_finished(card: Card)->void:
	card.update_positions() 

func _on_card_hover(card: Card) -> void:
	#Get 2 cards before and 2 cards after hovered card for effect
	var card_index := card.get_index()
	
	var cards_in_hand := player_hand.get_children()
	
	var card_before_index_start: int = max(0, card_index - 2)
	var card_before_index_end: int =  min(card_index - 1, cards_in_hand.size() - 1)
	
	var card_after_index_start: int = max(0, card_index + 1)
	var card_after_index_end: int = min(card_index + 2, cards_in_hand.size() - 1)
	
	if card_before_index_start <= card_before_index_end:
		for i in range(card_before_index_start, card_before_index_end + 1):
			var card_before: Card = cards_in_hand[i]
			
			var tilt_left_position: Vector2 = card_before.original_position
			var tween_left := get_tree().create_tween().set_parallel(true)
			
			tilt_left_position.x -= CARD_HOVER_X_OFFSET
			tween_left.tween_property(card_before, "global_position", tilt_left_position, 0.1)
	
	if card_after_index_start <= card_after_index_end:
		for i in range(card_after_index_start, card_after_index_end + 1):
			var card_after: Card = cards_in_hand[i]
			
			var tween_right := get_tree().create_tween()
			var tilt_right_position: Vector2 = card_after.original_position
			
			tilt_right_position.x += CARD_HOVER_X_OFFSET
			
			tween_right.tween_property(card_after, "global_position", tilt_right_position, 0.1)

func _on_card_unhovered(card: Card) -> void:
	#Get 2 cards before and 2 cards after hovered card for effect
	var card_index := card.get_index()
	
	var cards_in_hand := player_hand.get_children()
	
	var card_before_index_start: int = max(0, card_index - 2)
	var card_before_index_end: int =  min(card_index - 1, cards_in_hand.size() - 1)
	
	var card_after_index_start: int = max(0, card_index + 1)
	var card_after_index_end: int = min(card_index + 2, cards_in_hand.size() - 1)
	
	if card_before_index_start <= card_before_index_end:
		for i in range(card_before_index_start, card_before_index_end + 1):
			var card_before: Card = cards_in_hand[i]
			card_before.set_original_card_state()
	
	if card_after_index_start <= card_after_index_end:
		for i in range(card_after_index_start, card_after_index_end + 1):
			var card_after: Card = cards_in_hand[i]
			card_after.set_original_card_state()

func _on_card_discarded(card: Card) -> void:
	card.hoverable = false
	card.reparent(discard_pile)
	player_hand_list.erase(card)
	
	#Random degree between -20 and 20
	var random_rotation_offset := deg_to_rad(randi() % 41 - 20) 
	
	var tween := get_tree().create_tween().set_parallel(true)  
	tween.tween_property(card, "global_position", discard_pile.global_position, 0.25)
	tween.tween_property(card, "scale", Vector2(0.35, 0.35), 0.35)
	tween.tween_property(card, "rotation", random_rotation_offset, 0.25)
	
	_update_hand_position()
