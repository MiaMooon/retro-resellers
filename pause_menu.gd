extends Control
@onready var main = $"../../../.."

func _on_resume_pressed() -> void:
	main.pauseMenu()

func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_save_pressed() -> void:
	pass # Replace with function body.


func _on_load_pressed() -> void:
	pass # Replace with function body.


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
