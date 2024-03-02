extends Node2D

class_name Player

var hand: Array[Card]

var player_name: String

func play_card(card: Card) -> void:
	var selected_card: int = hand.find(card)
	if selected_card:
		hand[selected_card].play()

func set_hand(hand_array: Array[Card]) -> void:
	hand = hand_array
