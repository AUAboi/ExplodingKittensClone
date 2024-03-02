extends CardEffect

class_name ExplodingKitten


func draw(player: Player) -> void: 
	EventBus.exploding_drawn.emit(player)
	
	var hand: 

func play(player: Player, target: Player) -> void:
	pass
