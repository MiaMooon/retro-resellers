extends Control

var testCube := preload("res://Objects/TestCube.tscn")

func _on_back_pressed() -> void:
	$".".hide()
	$"../Phone".show()

@onready var player = get_node("../../..")

func _on_test_button_pressed() -> void:
	get_node("../../../../BuildingSystem").set_placeable_scene(preload("res://Objects/TestCube.tscn"))
	$"../Phone".hide()
	$".".hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
