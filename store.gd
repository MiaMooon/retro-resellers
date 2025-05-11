extends Node3D

@onready var pause_menu = $"CharacterBody3D/Head/Camera3D/Pause Menu"
@onready var phoneobj = $CharacterBody3D/Head/Camera3D/Phone

var paused = false
var phone = false

func _ready():
	pause_menu.hide()
	$StoreName.text = str(Bank.StoreName)
	Engine.time_scale = 1
	paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		paused = false
	else:
		pause_menu.show()
		phoneobj.hide()
		Engine.time_scale = 0
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		paused = true

func PhoneMenu():
	if phone:
		phoneobj.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		phone = 0
	else:
		phoneobj.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		phone = 1
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		pauseMenu()
	if Input.is_action_just_pressed("OpenPhone"):
		PhoneMenu()
		
	if $CharacterBody3D/Head/Camera3D/BuildMenu.visible and Input.is_action_just_pressed("OpenPhone"):
		$CharacterBody3D/Head/Camera3D/BuildMenu.hide()
		
