extends RigidBody2D
class_name Target

## Special target object for win condition
## Similar to blocks but tracked separately for level completion

# === TUNABLE PARAMETERS ===
@export_group("Target Settings")
@export var max_health: float = 30.0              ## Targets are tougher than normal blocks
@export var target_mass: float = 3.0              ## Mass affects how easily targets fall
@export var friction: float = 0.8                 ## Friction with other surfaces
@export var bounce_factor: float = 0.2            ## How bouncy the target is

@export_group("Visual Settings")
@export var target_size: Vector2 = Vector2(40, 60) ## Size of the target (taller than blocks)
@export var target_color: Color = Color.CRIMSON    ## Distinctive red color

@export_group("Destruction")
@export var damage_threshold: float = 5.0         ## Minimum damage to register

# === STATE VARIABLES ===
var current_health: float
var is_destroyed: bool = false

# === SIGNALS ===
signal target_destroyed(target: Target)

func _ready() -> void:
	current_health = max_health

	# Add to targets group for identification and gravity management
	add_to_group("targets")

	# Configure physics properties
	mass = target_mass
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = bounce_factor
	physics_material_override.friction = friction

	# Set collision layers
	collision_layer = 8  # Layer 4: Targets
	collision_mask = 1 | 2 | 4  # Collide with projectiles (1), blocks (2), terrain (4)

	# Create visual and collision
	create_target_visual()

	# Start with NO GRAVITY - stays off until first shot
	gravity_scale = 0.0

	print("Target created with health: ", max_health)

func enable_gravity() -> void:
	"""Enable gravity when first shot is fired"""
	gravity_scale = 1.0
	# Set to sleeping so targets don't move until hit
	sleeping = true

func _physics_process(_delta: float) -> void:
	# Check if fallen off screen (kill plane) - count as destroyed for win condition
	if global_position.y > 1200:
		print("Target fell off screen, counting as destroyed")
		if not is_destroyed:
			destroy()

func create_target_visual() -> void:
	"""Create visual representation and collision shape"""
	# Create collision shape
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	var rect_shape: RectangleShape2D = RectangleShape2D.new()
	rect_shape.size = target_size
	collision_shape.shape = rect_shape
	add_child(collision_shape)

	# Create visual rectangle (body)
	var rect_visual: Polygon2D = Polygon2D.new()
	var half_size: Vector2 = target_size / 2.0
	rect_visual.polygon = PackedVector2Array([
		Vector2(-half_size.x, -half_size.y),
		Vector2(half_size.x, -half_size.y),
		Vector2(half_size.x, half_size.y),
		Vector2(-half_size.x, half_size.y)
	])
	rect_visual.color = target_color
	add_child(rect_visual)

	# Add border
	var border: Line2D = Line2D.new()
	border.width = 3.0
	border.default_color = Color.DARK_RED
	border.add_point(Vector2(-half_size.x, -half_size.y))
	border.add_point(Vector2(half_size.x, -half_size.y))
	border.add_point(Vector2(half_size.x, half_size.y))
	border.add_point(Vector2(-half_size.x, half_size.y))
	border.add_point(Vector2(-half_size.x, -half_size.y))
	add_child(border)

	# Add crosshair to mark as target
	var crosshair: Line2D = Line2D.new()
	crosshair.width = 2.0
	crosshair.default_color = Color.WHITE
	# Vertical line
	crosshair.add_point(Vector2(0, -half_size.y * 0.5))
	crosshair.add_point(Vector2(0, half_size.y * 0.5))
	add_child(crosshair)

	var crosshair_h: Line2D = Line2D.new()
	crosshair_h.width = 2.0
	crosshair_h.default_color = Color.WHITE
	# Horizontal line
	crosshair_h.add_point(Vector2(-half_size.x * 0.5, 0))
	crosshair_h.add_point(Vector2(half_size.x * 0.5, 0))
	add_child(crosshair_h)

func take_damage(damage_amount: float) -> void:
	"""Apply damage to the target"""
	if is_destroyed:
		return

	# Ignore very small damage
	if damage_amount < damage_threshold:
		return

	current_health -= damage_amount
	print("TARGET took damage: ", damage_amount, " | Remaining health: ", current_health)
	if has_node("/root/Logger"):
		get_node("/root/Logger").call("log_damage", name, damage_amount, current_health)

	# Update visual based on damage
	update_damage_visual()

	# Check if destroyed
	if current_health <= 0:
		destroy()

func update_damage_visual() -> void:
	"""Update target appearance based on remaining health"""
	var health_percent: float = current_health / max_health

	# Find the polygon visual and change opacity/color
	for child in get_children():
		if child is Polygon2D:
			# Make more transparent and darker as health decreases
			var damaged_color: Color = target_color.darkened(1.0 - health_percent)
			damaged_color.a = 0.5 + (health_percent * 0.5)
			child.color = damaged_color

func destroy() -> void:
	"""Destroy the target"""
	if is_destroyed:
		return

	is_destroyed = true
	print("TARGET DESTROYED at: ", global_position)
	if has_node("/root/Logger"):
		get_node("/root/Logger").call("log_destruction", "TARGET: " + name, global_position)

	# Emit signal for level manager
	target_destroyed.emit(self)

	# Optional: Create destruction effect
	# Defer to avoid physics query errors
	call_deferred("create_destruction_effect")

	# Remove from scene
	queue_free()

func create_destruction_effect() -> void:
	"""Create a special destruction effect for targets"""
	# Create a larger explosion of debris for targets
	for i in range(8):
		var debris: RigidBody2D = RigidBody2D.new()
		debris.global_position = global_position

		# Small collision shape
		var debris_collision: CollisionShape2D = CollisionShape2D.new()
		var debris_shape: CircleShape2D = CircleShape2D.new()
		debris_shape.radius = 5.0
		debris_collision.shape = debris_shape
		debris.add_child(debris_collision)

		# Visual
		var debris_visual: Polygon2D = Polygon2D.new()
		var points: PackedVector2Array = []
		for j in range(8):
			var angle: float = (j / 8.0) * TAU
			points.append(Vector2(cos(angle), sin(angle)) * 5.0)
		debris_visual.polygon = points
		debris_visual.color = Color.RED
		debris.add_child(debris_visual)

		# Physics
		debris.collision_layer = 0
		debris.collision_mask = 4  # Only collide with terrain
		var explosion_dir: Vector2 = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		debris.linear_velocity = explosion_dir * randf_range(200, 400)
		debris.angular_velocity = randf_range(-10, 10)

		# Add to scene
		get_tree().root.add_child(debris)

		# Auto-cleanup debris
		var timer: Timer = Timer.new()
		timer.wait_time = 3.0
		timer.one_shot = true
		timer.timeout.connect(func(): debris.queue_free())
		debris.add_child(timer)
		timer.start()
