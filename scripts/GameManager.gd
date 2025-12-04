extends Node
class_name GameManager

## Game manager for tracking targets, shots, and win/lose conditions
## Attach this to each level scene

# === GAME STATE ===
var total_targets: int = 0
var destroyed_targets: int = 0
var shots_remaining: int = 3
var total_shots: int = 3
var game_won: bool = false
var game_lost: bool = false
var game_over: bool = false

# === SIGNALS ===
signal shot_fired(shots_left: int)
signal game_victory()
signal game_defeat()
signal shots_updated(current: int, total: int)

func _ready() -> void:
	# Wait for scene to be fully loaded
	call_deferred("initialize_game")

func initialize_game() -> void:
	"""Initialize game state and connect to all targets"""
	# Find all targets in the scene
	var targets: Array[Node] = get_tree().get_nodes_in_group("targets")
	total_targets = targets.size()
	destroyed_targets = 0
	game_won = false
	game_lost = false
	game_over = false

	print("Game initialized with ", total_targets, " targets and ", total_shots, " shots")
	if has_node("/root/Logger"):
		get_node("/root/Logger").call("log_level_event", "Level initialized: %d targets, %d shots" % [total_targets, total_shots])

	# Connect to each target's destruction signal
	for target in targets:
		if target.has_signal("target_destroyed"):
			target.target_destroyed.connect(_on_target_destroyed)

	# Find slingshot and connect to its launch signal
	var slingshot = get_tree().root.find_child("Slingshot", true, false)
	if slingshot and slingshot.has_signal("projectile_launched"):
		slingshot.projectile_launched.connect(_on_projectile_launched)

	# Emit initial shots count
	shots_updated.emit(shots_remaining, total_shots)

func _on_projectile_launched() -> void:
	"""Called when slingshot launches a projectile"""
	if game_over:
		return

	shots_remaining -= 1
	print("Shot fired! Remaining: ", shots_remaining, "/", total_shots)
	if has_node("/root/Logger"):
		get_node("/root/Logger").call("log_level_event", "Shot fired: %d remaining" % shots_remaining)

	shot_fired.emit(shots_remaining)
	shots_updated.emit(shots_remaining, total_shots)

	# Check lose condition after shot is fired
	if shots_remaining <= 0:
		call_deferred("check_defeat")

func _on_target_destroyed(_target: Node) -> void:
	"""Handle when a target is destroyed"""
	destroyed_targets += 1
	print("Target destroyed! Progress: ", destroyed_targets, "/", total_targets)
	if has_node("/root/Logger"):
		get_node("/root/Logger").call("log_level_event", "Target destroyed: %d/%d" % [destroyed_targets, total_targets])

	# Check win condition
	if destroyed_targets >= total_targets and not game_over:
		game_won = true
		game_over = true
		if has_node("/root/Logger"):
			get_node("/root/Logger").call("log_level_event", "LEVEL COMPLETE! All targets destroyed!")
		call_deferred("show_victory")

func check_defeat() -> void:
	"""Check if player has lost (no shots remaining and targets still exist)"""
	if game_over:
		return

	# Wait a bit for any projectiles to finish their physics
	await get_tree().create_timer(2.0).timeout

	if destroyed_targets < total_targets and shots_remaining <= 0 and not game_over:
		game_lost = true
		game_over = true
		print("=== LEVEL FAILED! No shots remaining ===")
		if has_node("/root/Logger"):
			get_node("/root/Logger").call("log_level_event", "LEVEL FAILED! No shots remaining")
		show_defeat()

func show_victory() -> void:
	"""Display victory message"""
	print("=== LEVEL COMPLETE! ALL TARGETS DESTROYED! ===")
	game_victory.emit()

func show_defeat() -> void:
	"""Display defeat message"""
	print("=== LEVEL FAILED! Out of shots ===")
	game_defeat.emit()

func can_shoot() -> bool:
	"""Check if player can still shoot"""
	return shots_remaining > 0 and not game_over

func restart_level() -> void:
	"""Restart the current level"""
	if has_node("/root/Logger"):
		get_node("/root/Logger").call("log_level_event", "Level restarting")
	get_tree().reload_current_scene()
