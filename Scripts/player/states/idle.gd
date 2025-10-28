extends PlayerState


@export var sprite : AnimatedSprite2D

func enter(_previous_state_path : String, _data := {}) -> void:
	sprite.play('Idle')
	#player.animation_player.play('Idle')
	
func physics_update(_delta:float) -> void:
	player.velocity.x = 0
	player.velocity.y = 0
	player.move_and_slide()
