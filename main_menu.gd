extends Control

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Story.tscn")

func _on_load_game_pressed() -> void:
	pass # Replace with function body.

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()
