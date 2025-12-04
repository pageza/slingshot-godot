extends RigidBody2D
class_name Projectile

## Physics-based projectile for slingshot game
## Handles collision detection, damage dealing, and self-cleanup

# === TUNABLE PARAMETERS ===
@export_group("Physics Settings")
@export var projectile_mass: float = 1.0          ## Mass affects momentum and impact
@export var bounce_factor: float = 0.3            ## Bounciness (0 = no bounce, 1 = perfect bounce)
@export var friction: float = 0.5                 ## Surface friction
@export var gravity_scale_value: float = 1.0     ## Multiplier for gravity effect

@export_group("Damage Settings")
@export var base_damage: float = 10.0             ## Base damage on impact
@export var velocity_damage_multiplier: float = 0.5  ## Additional damage based on impact speed

@export_group("Lifetime")
@export var max_lifetime: float = 10.0            ## Auto-destroy after this many seconds
@export var sleep_timer_threshold: float = 2.0    ## Destroy if stopped moving for this long

# === STATE VARIABLES ===
var lifetime: float = 0.0
var sleep_timer: float = 0.0
var has_hit_something: bool = false

func _ready() -> void:
	# Configure physics properties
	mass = projectile_mass
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = bounce_factor
	physics_material_override.friction = friction
	gravity_scale = gravity_scale_value

	# Enable contact monitoring for collision detection
	contact_monitor = true
	max_contacts_reported = 5

	# Set collision layers
	collision_layer = 1  # Layer 1: Projectiles
	collision_mask = 2 | 4 | 8  # Collide with blocks (2), terrain (4), targets (8)

	# Connect body collision signal
	body_entered.connect(_on_body_entered)

	# Create visual representation
	create_visual()

	print("Projectile spawned at: ", global_position)

func create_visual() -> void:
	"""Create simple circular visual for projectile"""
	# Create collision shape
	var collision_shape: CollisionShape2D = CollisionShape2D.new()
	var circle_shape: CircleShape2D = CircleShape2D.new()
	circle_shape.radius = 15.0
	collision_shape.shape = circle_shape
	add_child(collision_shape)

	# Create visual polygon (circle approximation)
	var polygon: Polygon2D = Polygon2D.new()
	var points: PackedVector2Array = []
	var segments: int = 16
	for i in range(segments):
		var angle: float = (i / float(segments)) * TAU
		points.append(Vector2(cos(angle), sin(angle)) * 15.0)
	polygon.polygon = points
	polygon.color = Color.DARK_RED
	add_child(polygon)

	# Add outline
	var outline: Line2D = Line2D.new()
	outline.width = 2.0
	outline.default_color = Color.RED
	for point in points:
		outline.add_point(point)
	outline.add_point(points[0])  # Close the loop
	add_child(outline)

func _physics_process(delta: float) -> void:
	lifetime += delta

	# Check if projectile has stopped moving
	if linear_velocity.length() < 10.0:
		sleep_timer += delta
		if sleep_timer >= sleep_timer_threshold:
			print("Projectile stopped moving, cleaning up")
			if has_node("/root/Logger"):
				get_node("/root/Logger").call("log_debug", "Projectile cleanup: stopped moving", "Projectile")
			queue_free()
	else:
		sleep_timer = 0.0

	# Auto-cleanup after max lifetime
	if lifetime >= max_lifetime:
		print("Projectile lifetime expired")
		if has_node("/root/Logger"):
			get_node("/root/Logger").call("log_debug", "Projectile cleanup: lifetime expired", "Projectile")
		queue_free()

func _on_body_entered(body: Node) -> void:
	"""Handle collision with other physics bodies"""
	has_hit_something = true

	# Calculate impact force based on velocity
	var impact_velocity: float = linear_velocity.length()
	var total_damage: float = base_damage + (impact_velocity * velocity_damage_multiplier)

	print("Projectile hit: ", body.name, " with velocity: ", impact_velocity, " damage: ", total_damage)
	if has_node("/root/Logger"):
		get_node("/root/Logger").call("log_collision", "Projectile", body.name, impact_velocity)

	# Check if body can take damage
	if body.has_method("take_damage"):
		body.take_damage(total_damage)

	# Special handling for targets
	if body.is_in_group("targets"):
		print("Hit a target!")
		if has_node("/root/Logger"):
			get_node("/root/Logger").call("log_info", "Projectile hit target: %s" % body.name, "Projectile")

	# Optional: Make projectile less bouncy after first hit
	if physics_material_override:
		physics_material_override.bounce *= 0.5

func _exit_tree() -> void:
	"""Cleanup when removed from scene"""
	print("Projectile destroyed at position: ", global_position)
