class_name FiniteStateMachine extends Node

@export var initial_state : State = null

@onready var state : State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()

func _ready() -> void:
	for state_node : State in find_children('*', 'State'):
		state_node.finished.connect(_transition_to_next_state)
	
	await  owner.ready
	state.enter('')

func _unhandled_input(_event : InputEvent) -> void:
	state.handle_input(_event)

func _process(_delta : float) -> void:
	state.update(_delta)
	
func _physics_process(_delta : float) -> void:
	state.physics_update(_delta)
	_check_state_transitions()
	
func _check_state_transitions() -> void:
	var player = owner as Player
	var current_map_coord = player.world_to_map_coord(player.global_position)
	var next_map_coord = current_map_coord

	# Apenas verifica o Input se estiver no estado Idle e não estiver já a mover-se
	if state.name == "Idle":
		var iso_vector = player.get_iso_movement_vector()

		if iso_vector.length_squared() > 0:
			var dir_x = 0
			var dir_y = 0

			# 1. Mapeamento de Input para a Célula da Grelha
			# Baseado nos teus 8 vetores de input (iso_vector)

			# O sistema de sub-divisão triangular é complexo de implementar
			# APENAS com o Input. Vamos simplificar para 8 direções de grelha.

			# Mapeamento do Input de 8 direções para as coordenadas da grelha:
			if Input.is_action_pressed("ui_up"):dir_y -= 1
			if Input.is_action_pressed("ui_down"):  dir_y += 1
			if Input.is_action_pressed("ui_left"):  dir_x -= 1
			if Input.is_action_pressed("ui_right"): dir_x += 1

			# Se houver input ativo:
			if dir_x != 0 or dir_y != 0:
			# O movimento Isométrico 2:1 usa esta lógica para mapear
			# X, Y (Input) para X_mapa, Y_mapa (Célula)

				var move_target_x = 0
				var move_target_y = 0

				# Se for diagonal (Ex: Cima + Direita = X+1, Y+0 na Grelha)
				if dir_x != 0 and dir_y != 0:
					# Movimento diagonal no ecrã = movimento cardinal na grelha
					move_target_x = dir_x
					move_target_y = 0 # No isométrico 2:1, o movimento X+Y vira um eixo
				else:
					# Movimento cardinal no ecrã = movimento diagonal na grelha
					if dir_y < 0: # Cima (ui_up) -> Diagonal Esquerda/Cima
						move_target_x = -1
						move_target_y = 0
					elif dir_y > 0: # Baixo (ui_down) -> Diagonal Direita/Baixo
						move_target_x = 1
						move_target_y = 0
					elif dir_x < 0: # Esquerda (ui_left) -> Diagonal Esquerda/Baixo
						move_target_x = -1
						move_target_y = 1
					elif dir_x > 0: # Direita (ui_right) -> Diagonal Direita/Cima
						move_target_x = 1
						move_target_y = 1

				# (NOTA: A matriz de mapeamento X/Y para X_mapa/Y_mapa pode variar ligeiramente
				# dependendo da orientação exata do teu TileMap, mas este é o padrão Isométrico 2:1)

				next_map_coord = current_map_coord + Vector2i(move_target_x, move_target_y)

				# 2. Verificação de Colisão (Se o próximo tile é um obstáculo)
				# Podes usar 'tilemap_node.get_cell_tile_data(layer, next_map_coord)'
				# para verificar se o tile de destino tem uma propriedade 'Is_Blocked'.
				var is_blocked = false 
				# Adicionar lógica de verificação de colisão aqui

				if not is_blocked:
					# Transita para o novo estado de movimento
					_transition_to_next_state("Walking", {"target_tile": next_map_coord})
					return # Não verifica mais transições
#func _check_state_transitions() -> void:
	#var next_state_name := ''
	#var player = owner as Player
	#
	#match state.name:
		#'Idle':
			#if Input.is_action_just_pressed("ui_accept"):
				#next_state_name = 'Jumping'
			#elif player.get_iso_movement_vector().length_squared() > 0:
				#next_state_name = 'Walking'
				#
		#'Walking':
			#if Input.is_action_just_pressed("ui_accept"):
				#next_state_name = 'Jumping'
			#elif player.get_iso_movement_vector().length_squared() == 0:
				#next_state_name = 'Idle'
	#if next_state_name != '':
		#_transition_to_next_state(next_state_name)
		
func _transition_to_next_state(target_state_path : String, _data : Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + 'Trying to transition to state ' + target_state_path + ' but it does not exist.')
		return
		
	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path)
