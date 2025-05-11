extends Node3D

@export var grid_size: float = 1.0
@export var use_grid_snap: bool = true
@export var camera: Camera3D
@export var player_body: Node3D
@export var ground_detection_ray_length: float = 100.0
@export var surface_offset: float = 0.01

var current_preview: Node3D = null
var current_scene: PackedScene = null
var rotation_y_degrees: float = 0.0

func _ready():
	if camera == null:
		push_error("Camera not assigned.")
	if player_body == null:
		push_warning("Player reference not assigned — raycast might hit player.")

func _process(_delta):
	if current_scene == null or camera == null or !is_inside_tree():
		return

	var space_state = get_world_3d().direct_space_state
	var from: Vector3 = camera.global_position
	var to: Vector3 = from + -camera.global_transform.basis.z * ground_detection_ray_length

	# Perform raycasting
	var ray_query = PhysicsRayQueryParameters3D.create(from, to)
	if player_body:
		ray_query.exclude = [player_body.get_rid()]

	var ray_result = space_state.intersect_ray(ray_query)

	if ray_result and current_preview and current_preview.is_inside_tree():
		# Validate and calculate position based on ray hit
		var position: Vector3 = ray_result.position if "position" in ray_result else Vector3.ZERO
		var normal: Vector3 = ray_result.normal if "normal" in ray_result else Vector3.UP
		position += normal * surface_offset

		# Snap to grid if enabled
		if use_grid_snap:
			position = snap_to_grid(position)

		# Adjust for the collision shape offset
		var collision_offset = get_collision_shape_offset(current_preview)
		position += collision_offset

		# Perform collision check and adjust position
		position = adjust_position_for_collisions(position)

		# Perform ground raycast for accurate placement
		position.y = get_ground_position(position, collision_offset.y)

		# Apply the final position and rotation
		current_preview.global_position = position
		current_preview.rotation_degrees.y = rotation_y_degrees
		current_preview.visible = true
	elif current_preview:
		current_preview.visible = false

func adjust_position_for_collisions(position: Vector3) -> Vector3:
	# Check for collisions and adjust position to prevent clipping
	var space_state = get_world_3d().direct_space_state
	var collision_query = PhysicsShapeQueryParameters3D.new()
	collision_query.transform = Transform3D(Basis(), position)  # Corrected to Transform3D
	collision_query.shape = get_preview_collision_shape(current_preview)
	collision_query.margin = 0.01

	var collision_results = space_state.intersect_shape(collision_query, 32)
	if collision_results.size() > 0:
		# If there are collisions, adjust position along the collision normal
		for result in collision_results:
			var collision_normal = result.normal if "normal" in result else Vector3.UP
			position += collision_normal * surface_offset
	return position


func get_preview_collision_shape(node: Node3D) -> Shape3D:
	# Retrieve the collision shape of the preview if it exists
	var static_body = node.get_node_or_null("StaticBody3D")
	if static_body:
		for child in static_body.get_children():
			if child is CollisionShape3D and child.shape:
				return child.shape
	return null

func get_collision_shape_offset(node: Node3D) -> Vector3:
	# Calculate the offset based on the collision shape's size
	var static_body := node.get_node_or_null("StaticBody3D")
	if static_body:
		for child in static_body.get_children():
			if child is CollisionShape3D and child.shape:
				match child.shape:
					BoxShape3D:
						return Vector3(0, child.shape.size.y / 2.0, 0)
					CapsuleShape3D, CylinderShape3D:
						return Vector3(0, child.shape.height / 2.0, 0)
					SphereShape3D:
						return Vector3(0, child.shape.radius, 0)
	return Vector3.ZERO

func get_ground_position(position: Vector3, object_height: float) -> float:
	# Perform ground raycast for accurate Y placement
	var space_state = get_world_3d().direct_space_state
	var ground_from = Vector3(position.x, position.y + 1.0, position.z)
	var ground_to = Vector3(position.x, position.y - ground_detection_ray_length, position.z)

	var ground_query = PhysicsRayQueryParameters3D.create(ground_from, ground_to)
	if player_body:
		ground_query.exclude = [player_body.get_rid()]

	var ground_result = space_state.intersect_ray(ground_query)
	if ground_result:
		# Adjust the position to account for the object's height
		return ground_result.position.y + surface_offset + object_height
	return position.y

func snap_to_grid(position: Vector3) -> Vector3:
	# Snap position to the grid
	position.x = round(position.x / grid_size) * grid_size
	position.z = round(position.z / grid_size) * grid_size
	return position

func _input(event):
	if current_preview == null or !current_preview.is_inside_tree():
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and current_preview.visible:
			var placed = current_scene.instantiate()
			if is_instance_valid(placed):
				placed.global_position = current_preview.global_position
				placed.rotation_degrees.y = current_preview.rotation_degrees.y
				get_parent().add_child(placed)
				print_debug("Object placed at: ", placed.global_position)

func _unhandled_input(event):
	if current_preview == null or !current_preview.is_inside_tree():
		return

	if event.is_action_pressed("rotate_90"):
		rotation_y_degrees = fmod(rotation_y_degrees + 90.0, 360.0)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			rotation_y_degrees += 5.0
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			rotation_y_degrees -= 5.0
	elif event.is_action_pressed("toggle_snap"):
		use_grid_snap = !use_grid_snap

func set_placeable_scene(scene: PackedScene) -> void:
	if current_preview:
		current_preview.queue_free()
	current_scene = scene

	current_preview = current_scene.instantiate()
	add_child(current_preview)
	rotation_y_degrees = 0.0

	disable_preview_collision(current_preview)
	current_preview.visible = false

func disable_preview_collision(node: Node) -> void:
	for child in node.get_children():
		if child is CollisionShape3D:
			child.disabled = true
		elif child is PhysicsBody3D:
			child.collision_layer = 0
			child.collision_mask = 0
		elif child is MeshInstance3D:
			apply_ghost_material(child)
		disable_preview_collision(child)

func apply_ghost_material(mesh: MeshInstance3D):
	var ghost_material := StandardMaterial3D.new()
	ghost_material.albedo_color = Color(0.8, 0.8, 1.0, 0.3)
	ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ghost_material.flags_transparent = true
	mesh.set_surface_override_material(0, ghost_material)
