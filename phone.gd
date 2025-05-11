extends Control

@onready var BuildMenu = $"../BuildMenu"
@onready var phone = $"."

var build = false

func _on_build_pressed() -> void:
	build = true
	phone.hide()
	BuildMenu.show()
