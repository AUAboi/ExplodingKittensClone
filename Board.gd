extends Node2D

var defuse_card_scene: PackedScene = preload("res://Cards/Defuse/DefuseCard.tscn")
var deck: Array[Card]
var player_hand: Array[Card]

const CardSize = Vector2(125,175)

@onready var hand: Node = $Hand
@onready var CentreCardOval = Vector2(get_viewport().size) * Vector2(0.5, 1.25)
@onready var Hor_rad = get_viewport().size.x*0.45
@onready var Ver_rad = get_viewport().size.y*0.4
var angle = deg_to_rad(90) - 0.55
var OvalAngleVector = Vector2()
var spread_curve = preload("res://UI/resources/spread_curve.tres") as Curve
var height_curve = preload("res://UI/resources/height_curve.tres") as Curve
const angle_curve := preload("res://UI/resources/angle_curve.tres") as Curve

@export var card_spread_x:float = 2.0
@export var card_spread_y:float = 1.0
@export var card_speed:float = 100.0
@export var card_spread_angle:float = 1.0

func _ready() -> void:
	_create_deck()
	var i = 0
	for card in deck:
		pass

func _process(delta:float) -> void:
	var card_count := deck.size()
	var separation := 1.0/card_count
	var offset := separation * 0.5
	for index in card_count:
		var card := deck[index] as Card
		var hand_ratio := index * separation + offset
		var destination := _compute_destination(hand_ratio)
		_move_card(card, destination, delta)
		
func _create_deck() -> void:
	var path = "res://Cards/Defuse/Resources/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				_load_card(path + file_name, defuse_card_scene)
				
			file_name = dir.get_next()

func _load_card(path: String, scene: PackedScene) -> void:
	var card: Card = scene.instantiate() as Card
	card.card_stats = load(path)
	deck.append(card)

func deck_ratio_calc(card, index):
	var deck_ratio = 0.5
	if deck.size() > 1:
		deck_ratio = float(index) / float(deck.size() - 1)
		print(deck_ratio)
		
func card_rotation_method(card: Card):
	OvalAngleVector = Vector2(Hor_rad * cos(angle), - Ver_rad * sin(angle))
	var target_position = CentreCardOval + OvalAngleVector - card.size/2
	var target_scale = card.scale * CardSize/card.size
	hand.add_child(card)
	var tween = get_tree().create_tween()
	tween.tween_property(card, "scale", target_scale, 0.5)
	tween.tween_property(card, "position", target_position, 0.5)
	

	angle += 0.25

func _compute_destination(hand_ratio:float) -> Transform2D:
	# Compute displacement:
	var displacement := Vector2(
		spread_curve.sample(hand_ratio) * card_spread_x,
		height_curve.sample(hand_ratio) * card_spread_y
	)

	# Compute rotation
	var rotation = angle_curve.sample(hand_ratio) * card_spread_angle

	# Decompose the hand transform in position and rotation
	var pos := global_transform.origin
	var rot := global_transform.get_rotation()

	# Update position and rotation:
	pos += displacement
	rot += rotation

	# Compose the result
	return Transform2D(rot, pos)

func get_approach_factor(time:float, delta:float) -> float:
	const EPSILON := 0.00001
	const SCALE := 1000.0
	if is_nan(time) or time == INF:
		return 0.0

	if time < EPSILON / SCALE:
		return 1.0

	var base := pow(EPSILON, 1.0 / (time * SCALE))
	return 1.0 - pow(base, delta * SCALE)

func _move_card(card:Card, destination:Transform2D, delta:float) -> void:
	var time = 1.0 
	# Get the approach factor
	var factor := get_approach_factor(time, delta)

	# Interpolate the transforms
	card.global_transform = card.global_transform.interpolate_with(destination, factor)
