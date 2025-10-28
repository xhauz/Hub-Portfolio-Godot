class_name Player extends CharacterBody2D

@export var speed := 500.0
@export var gravity := 4000.0
@export var jump_impulse := 1800.0
@export var tilemap_node: TileMapLayer
@export var sprite_height_offset: float = -20.0
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite

const TILE_SIZE_HALF := Vector2i(16, 8)

func get_iso_movement_vector() -> Vector2:
	var direction : Vector2 = Vector2.ZERO
	direction.x = Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')
	direction.y = Input.get_action_strength('ui_down') - Input.get_action_strength('ui_up')
	
	direction = direction.normalized()
	
	var movement_on_screen = Vector2(direction.x , direction.y)
	var iso_vector = Vector2(
		movement_on_screen.x + movement_on_screen.y,
		(movement_on_screen.y - movement_on_screen.x) / 2.0
	)
	
	return iso_vector
	
func _update_animation(input_vector : Vector2) -> void:
	if input_vector.length_squared() > 0:
		if input_vector.x < 0:
			player_sprite.flip_h = true
		elif input_vector.x > 0:
			player_sprite.flip_h = false
	else:
		pass

func world_to_map_coord(world_pos : Vector2) -> Vector2i:
	return tilemap_node.local_to_map(world_pos)
	
func map_coord_to_world_center(map_coord : Vector2i) -> Vector2:
	var center_pos = tilemap_node.map_to_local(map_coord)
	return center_pos
