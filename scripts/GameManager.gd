extends Node
class_name GameManager

## Simple game manager for tracking targets and win condition
## Attach this to the TestLevel scene or use as autoload

var total_targets: int = 0
var destroyed_targets: int = 0
var game_won: bool = false

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

	print("Game initialized with ", total_targets, " targets")
	if has_node("/root/Logger"):
		get_node("/root/Logger").call("log_level_event", "Level initialized with %d targets" % total_targets)

	# Connect to each target's destruction signal
	for target in targets:
		if target.has_signal("target_destroyed"):
			target.target_destroyed.connect(_on_target_destroyed)

func _on_target_destroyed(_target: Node) -> void:
	"""Handle when a target is destroyed"""
	destroyed_targets += 1
	print("Target destroyed! Progress: ", destroyed_targets, "/", total_targets)
	if has_node("/root/Logger"):
		get_node("/root/Logger").call("log_level_event", "Target destroyed: %d/%d" % [destroyed_targets, total_targets])

	# Check win condition
	if destroyed_targets >= total_targets and not game_won:
		game_won = true
		if has_node("/root/Logger"):
			get_node("/root/Logger").call("log_level_event", "LEVEL COMPLETE! All targets destroyed!")
		call_deferred("show_victory")

func show_victory() -> void:
	"""Display victory message"""
	print("=== LEVEL COMPLETE! ALL TARGETS DESTROYED! ===")

	# Find UI label and update it
	var ui_layer: CanvasLayer = get_tree().root.get_node_or_null("TestLevel/UI")
	if ui_layer:
		var label: Label = ui_layer.get_node_or_null("InfoLabel")
		if label:
			label.text = "VICTORY!\n\nAll targets destroyed!\n\nPress F5 to restart"
			label.modulate = Color.GREEN
