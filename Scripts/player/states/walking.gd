#extends  PlayerState
#
#@export var sprite : AnimatedSprite2D
#
#func enter(_previous_state_path : String, _data := {}) -> void:
	#sprite.play('Walking')
	#
#func physics_update(_delta:float) -> void:
	#var iso_vector : Vector2 = player.get_iso_movement_vector()
	#
	#if iso_vector.length_squared() > 0:
		#var normalized_movement = iso_vector.normalized()
		#
		#player.velocity.x = normalized_movement.x * player.speed
		#player.velocity.y = normalized_movement.y * player.speed
	#
		#
	#else:
		#player.velocity.x = 0
		#player.velocity.y = 0
	#
	#player._update_animation(iso_vector)
	#player.move_and_slide()
	#


extends PlayerState

@export var move_duration: float = 0.2 # Duração da transição entre tiles (em segundos)
var target_map_coord: Vector2i = Vector2i.ZERO
var tween: Tween = null
var current_tile_center: Vector2 = Vector2.ZERO

func enter(_previous_state_path : String, _data := {}) -> void:
	# A coordenada para a qual fomos instruídos a mover (recebida via _data)
	target_map_coord = _data.get("target_tile", player.world_to_map_coord(player.global_position))
	
	# 1. Calcular o ponto de destino no mundo
	var target_world_pos = player.map_coord_to_world_center(target_map_coord)
	
	# 2. Iniciar o movimento suave (Tween)
	tween = player.create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Move a posição global do Player para o centro do próximo tile
	tween.tween_property(player, "global_position", target_world_pos, move_duration)
	
	# Conecta o sinal para saber quando o movimento terminou
	tween.finished.connect(_on_move_finished)
	
	# **Atenção:** O Player deve ter a gravidade desativada durante este movimento se for 
	# apenas um movimento horizontal/diagonal.

func _on_move_finished() -> void:
	# O movimento terminou. Transita de volta para Idle.
	finished.emit(IDLE)
	
# Não precisamos de physics_update ou update aqui, o Tween faz o trabalho.
func exit() -> void:
	if tween != null and tween.is_valid():
		tween.kill() # Garante que o Tween para se o estado mudar abruptamente
