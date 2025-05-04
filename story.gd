extends Control

func _on_button_pressed() -> void:
	Bank.PlayerMoney = 500000
	Bank.StoreName = $TextEdit.text
	get_tree().change_scene_to_file("res://Store.tscn")
