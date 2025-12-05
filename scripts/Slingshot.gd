extends Node2D
class_name Slingshot

## Slingshot drag-to-launch mechanic
## Handles player input, force calculation, trajectory preview, and projectile spawning

# === TUNABLE PARAMETERS ===
@export_group("Launch Settings")
@export var max_drag_distance: float = 200.0  ## Maximum pixels player can drag back
@export var force_multiplier: float = 10.0    ## Converts drag distance to launch force
@export var min_launch_force: float = 50.0    ## Minimum force required to launch

@export_group("Projectile Settings")
@export var projectile_scene: PackedScene      ## Projectile scene to spawn
@export var projectile_spawn_offset: Vector2 = Vector2(0, -100)  ## Offset from slingshot position (at fork junction)

@export_group("Visual Feedback")
@export var show_trajectory: bool = true       ## Show trajectory preview
@export var trajectory_points: int = 30        ## Number of points in trajectory arc
@export var trajectory_time_step: float = 0.1  ## Time between trajectory points

# === STATE VARIABLES ===
var is_dragging: bool = false
var drag_start_pos: Vector2 = Vector2.ZERO
var current_drag_pos: Vector2 = Vector2.ZERO
var game_manager: Node = null

# === SIGNALS ===
signal projectile_launched()

# === VISUAL NODES ===
var drag_line: Line2D
var trajectory_line: Line2D

func _ready() -> void:
	# Find GameManager
	game_manager = get_tree().root.find_child("GameManager", true, false)

	# Create drag direction line
	drag_line = Line2D.new()
	drag_line.width = 3.0
	drag_line.default_color = Color(1.0, 1.0, 0.0, 0.8)  # Yellow
	drag_line.z_index = 10
	add_child(drag_line)

	# Create trajectory preview line
	trajectory_line = Line2D.new()
	trajectory_line.width = 2.0
	trajectory_line.default_color = Color(0.0, 1.0, 1.0, 0.6)  # Cyan
	trajectory_line.z_index = 9
	add_child(trajectory_line)

func _process(_delta: float) -> void:
	# Handle input
	if Input.is_action_just_pressed("drag_start"):
		start_drag()

	if is_dragging:
		update_drag()
		update_visual_feedback()

	if Input.is_action_just_released("drag_release") and is_dragging:
		launch_projectile()
		end_drag()

func start_drag() -> void:
	"""Begin dragging from slingshot position"""
	# Check if shooting is allowed
	if game_manager and game_manager.has_method("can_shoot"):
		if not game_manager.can_shoot():
			print("Cannot shoot - out of shots or game over!")
			return

	var mouse_pos: Vector2 = get_global_mouse_position()

	# Only start drag if clicking near the slingshot
	if global_position.distance_to(mouse_pos) < 100.0:
		is_dragging = true
		drag_start_pos = global_position
		current_drag_pos = mouse_pos
		print("Drag started at: ", drag_start_pos)
		if has_node("/root/Logger"):
			get_node("/root/Logger").call("log_info", "Drag started", "Slingshot")

func update_drag() -> void:
	"""Update drag position while dragging"""
	current_drag_pos = get_global_mouse_position()

	# Clamp drag distance
	var drag_vector: Vector2 = current_drag_pos - drag_start_pos
	if drag_vector.length() > max_drag_distance:
		drag_vector = drag_vector.normalized() * max_drag_distance
		current_drag_pos = drag_start_pos + drag_vector

func update_visual_feedback() -> void:
	"""Update visual indicators during drag"""
	# Update drag line (shows pull direction)
	drag_line.clear_points()
	drag_line.add_point(to_local(drag_start_pos))
	drag_line.add_point(to_local(current_drag_pos))

	# Update trajectory preview
	if show_trajectory:
		draw_trajectory_preview()

func draw_trajectory_preview() -> void:
	"""Calculate and draw predicted trajectory arc with damping"""
	trajectory_line.clear_points()

	var launch_velocity: Vector2 = calculate_launch_velocity()
	if launch_velocity.length() < min_launch_force:
		return

	var start_pos: Vector2 = drag_start_pos + projectile_spawn_offset
	var gravity: Vector2 = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
	var linear_damping: float = 0.1  # Default physics linear damping

	# Simulate projectile path with damping
	var current_velocity: Vector2 = launch_velocity
	var current_pos: Vector2 = start_pos

	for i in range(trajectory_points):
		trajectory_line.add_point(to_local(current_pos))

		# Apply gravity
		current_velocity += gravity * trajectory_time_step

		# Apply linear damping (air resistance)
		var damping_factor = 1.0 / (1.0 + linear_damping * trajectory_time_step)
		current_velocity *= damping_factor

		# Update position
		current_pos += current_velocity * trajectory_time_step

func calculate_launch_velocity() -> Vector2:
	"""Convert drag vector into launch velocity"""
	# Launch direction is opposite of drag direction (pull back to launch forward)
	var drag_vector: Vector2 = drag_start_pos - current_drag_pos
	var launch_velocity: Vector2 = drag_vector * force_multiplier
	return launch_velocity

func launch_projectile() -> void:
	"""Spawn and launch projectile with calculated velocity"""
	if not projectile_scene:
		push_error("No projectile scene assigned to slingshot!")
		return

	var launch_velocity: Vector2 = calculate_launch_velocity()

	# Check minimum launch force
	if launch_velocity.length() < min_launch_force:
		print("Launch force too weak: ", launch_velocity.length())
		return

	# Spawn projectile
	var projectile: RigidBody2D = projectile_scene.instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position = global_position + projectile_spawn_offset

	# Apply launch force
	projectile.linear_velocity = launch_velocity

	print("Projectile launched with velocity: ", launch_velocity, " (magnitude: ", launch_velocity.length(), ")")
	if has_node("/root/Logger"):
		get_node("/root/Logger").call("log_projectile_launch", launch_velocity, projectile.global_position)

	# Emit signal to notify GameManager
	projectile_launched.emit()

func end_drag() -> void:
	"""End drag state and clear visual feedback"""
	is_dragging = false
	drag_line.clear_points()
	trajectory_line.clear_points()
	print("Drag ended")

func _draw() -> void:
	"""Draw slingshot visual (Y-shape on a stick)"""
	# Draw base on ground
	draw_circle(Vector2.ZERO, 10.0, Color.SADDLE_BROWN)

	# Draw vertical post/stick from ground up
	draw_line(Vector2(0, 0), Vector2(0, -80), Color.SADDLE_BROWN, 8.0)

	# Draw forked Y arms at top of stick
	draw_line(Vector2(0, -80), Vector2(-20, -120), Color.SADDLE_BROWN, 6.0)
	draw_line(Vector2(0, -80), Vector2(20, -120), Color.SADDLE_BROWN, 6.0)

	# Draw connection points at top of forks
	draw_circle(Vector2(-20, -120), 5.0, Color.DARK_ORANGE)
	draw_circle(Vector2(20, -120), 5.0, Color.DARK_ORANGE)
