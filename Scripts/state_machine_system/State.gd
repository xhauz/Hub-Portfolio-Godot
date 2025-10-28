class_name State extends Node

@warning_ignore("unused_signal")
signal finished(next_state_path : String, _data : Dictionary)

func handle_input(_event : InputEvent) -> void:
	pass
	
func enter(_previous_state_path : String, _data := {}) -> void:
	pass
	
func exit() -> void:
	pass

func update(_delta:float) -> void:
	pass

func physics_update(_delta:float) -> void:
	pass
