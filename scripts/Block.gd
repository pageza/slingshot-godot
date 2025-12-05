extends RigidBody2D
class_name Block

## Destructible block object
## Handles health, damage, and destruction

# === TUNABLE PARAMETERS ===
@export_group("Block Settings")
@export var max_health: float = 20.0              ## Total health before destruction
@export var block_mass: float = 2.0               ## Mass affects how easily blocks topple
@export var friction: float = 0.8                 ## Friction with other surfaces
@export var bounce_factor: float = 0.1            ## How bouncy the block is

@export_group("Visual Settings")
@export var block_size: Vector2 = Vector2(50, 50) ## Size of the block
@export var block_color: Color = Color.SANDY_BROWN ## Color of the block

@export_group("Destruction")
@export var damage_threshold: float = 5.0         ## Minimum damage to register
@export var break_on_high_velocity: bool = true   ## Break if moving too fast
@export var break_velocity_threshold: float = 500.0 ## Velocity that causes instant break

# === STATE VARIABLES ===
var current_health: float
var is_destroyed: bool = false
var initialization_complete: bool = false

func _ready() -> void:
	current_health = max_health

	# Add to blocks group for gravity management
	add_to_group("blocks")

	# Configure physics properties
	mass = block_mass
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = bounce_factor
	physics_material_override.friction = friction

	# Set collision layers
	collision_layer = 2  # Layer 2: Blocks
	collision_mask = 1 | 2 | 4  # Collide with projectiles (1), other blocks (2), terrain (4)

	# Create visual and collision
	create_block_visual()

	# Start with NO GRAVITY - stays off until first shot
	gravity_scale = 0.0
	initialization_complete = true

	print("Block created with health: ", max_health)

func enable_gravity() -> void:
	"""Enable gravity when first shot is fired"""
	gravity_scale = 1.0
	# Set to sleeping so blocks don't move until hit
	sleeping = true

func create_block_visual() -> void:
	"""Create visual representation and collision shape"""
	# Create collision shape
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	var rect_shape: RectangleShape2D = RectangleShape2D.new()
	rect_shape.size = block_size
	collision_shape.shape = rect_shape
	add_child(collision_shape)

	# Create visual rectangle
	var rect_visual: Polygon2D = Polygon2D.new()
	var half_size: Vector2 = block_size / 2.0
	rect_visual.polygon = PackedVector2Array([
		Vector2(-half_size.x, -half_size.y),
		Vector2(half_size.x, -half_size.y),
		Vector2(half_size.x, half_size.y),
		Vector2(-half_size.x, half_size.y)
	])
	rect_visual.color = block_color
	add_child(rect_visual)

	# Add border
	var border: Line2D = Line2D.new()
	border.width = 2.0
	border.default_color = Color.BLACK
	border.add_point(Vector2(-half_size.x, -half_size.y))
	border.add_point(Vector2(half_size.x, -half_size.y))
	border.add_point(Vector2(half_size.x, half_size.y))
	border.add_point(Vector2(-half_size.x, half_size.y))
	border.add_point(Vector2(-half_size.x, -half_size.y))
	add_child(border)

func _physics_process(_delta: float) -> void:
	# Only check velocity destruction after initialization is complete
	if not initialization_complete:
		return

	# Check for high-velocity destruction
	if break_on_high_velocity and linear_velocity.length() > break_velocity_threshold:
		print("Block destroyed by high velocity: ", linear_velocity.length())
		if has_node("/root/Logger"):
			get_node("/root/Logger").call("log_info", "Block destroyed by high velocity: %.2f" % linear_velocity.length(), "Block")
		destroy()

func take_damage(damage_amount: float) -> void:
	"""Apply damage to the block"""
	if is_destroyed:
		return

	# Ignore very small damage
	if damage_amount < damage_threshold:
		return

	current_health -= damage_amount
	print("Block took damage: ", damage_amount, " | Remaining health: ", current_health)
	if has_node("/root/Logger"):
		get_node("/root/Logger").call("log_damage", name, damage_amount, current_health)

	# Update visual based on damage (darker as more damaged)
	update_damage_visual()

	# Check if destroyed
	if current_health <= 0:
		destroy()

func update_damage_visual() -> void:
	"""Update block appearance based on remaining health"""
	var health_percent: float = current_health / max_health

	# Find the polygon visual and darken it
	for child in get_children():
		if child is Polygon2D:
			# Darken color as health decreases
			child.color = block_color.darkened(1.0 - health_percent)

func destroy() -> void:
	"""Destroy the block"""
	if is_destroyed:
		return

	is_destroyed = true
	print("Block destroyed at: ", global_position)
	if has_node("/root/Logger"):
		get_node("/root/Logger").call("log_destruction", name, global_position)

	# Optional: Create destruction effect (simple particles)
	# Defer to avoid physics query errors
	call_deferred("create_destruction_effect")

	# Remove from scene
	queue_free()

func create_destruction_effect() -> void:
	"""Simple destruction effect - spawn a few debris pieces"""
	# Create a few small debris rectangles
	for i in range(4):
		var debris: RigidBody2D = RigidBody2D.new()
		debris.global_position = global_position

		# Small collision shape
		var debris_collision: CollisionShape2D = CollisionShape2D.new()
		var debris_shape: RectangleShape2D = RectangleShape2D.new()
		debris_shape.size = Vector2(10, 10)
		debris_collision.shape = debris_shape
		debris.add_child(debris_collision)

		# Visual
		var debris_visual: Polygon2D = Polygon2D.new()
		debris_visual.polygon = PackedVector2Array([
			Vector2(-5, -5), Vector2(5, -5), Vector2(5, 5), Vector2(-5, 5)
		])
		debris_visual.color = block_color
		debris.add_child(debris_visual)

		# Physics
		debris.collision_layer = 0
		debris.collision_mask = 4  # Only collide with terrain
		debris.linear_velocity = Vector2(randf_range(-100, 100), randf_range(-200, -50))
		debris.angular_velocity = randf_range(-5, 5)

		# Add to scene
		get_tree().root.add_child(debris)

		# Auto-cleanup debris
		var timer: Timer = Timer.new()
		timer.wait_time = 2.0
		timer.one_shot = true
		timer.timeout.connect(func(): debris.queue_free())
		debris.add_child(timer)
		timer.start()
