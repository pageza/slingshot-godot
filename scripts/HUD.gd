extends CanvasLayer
class_name HUD

## HUD for displaying game information
## Shows shots remaining, level progress, and game state

# === NODE REFERENCES ===
@onready var shots_label: Label = $ShotsLabel
@onready var info_label: Label = $InfoLabel
@onready var restart_button: Button = $RestartButton
@onready var next_level_button: Button = $NextLevelButton

# === STATE ===
var game_manager: Node = null

func _ready() -> void:
	# Find and connect to GameManager
	game_manager = get_tree().root.find_child("GameManager", true, false)
	if game_manager:
		if game_manager.has_signal("shots_updated"):
			game_manager.shots_updated.connect(_on_shots_updated)
		if game_manager.has_signal("game_victory"):
			game_manager.game_victory.connect(_on_game_victory)
		if game_manager.has_signal("game_defeat"):
			game_manager.game_defeat.connect(_on_game_defeat)

	# Connect buttons
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
		restart_button.visible = false

	if next_level_button:
		next_level_button.pressed.connect(_on_next_level_pressed)
		next_level_button.visible = false

func _on_shots_updated(current: int, total: int) -> void:
	"""Update shots remaining display"""
	if shots_label:
		shots_label.text = "Shots: %d/%d" % [current, total]

		# Change color based on remaining shots
		if current <= 0:
			shots_label.modulate = Color.RED
		elif current <= 1:
			shots_label.modulate = Color.ORANGE
		else:
			shots_label.modulate = Color.WHITE

func _on_game_victory() -> void:
	"""Display victory message"""
	if info_label:
		info_label.text = "VICTORY!\n\nAll targets destroyed!"
		info_label.modulate = Color.GREEN
		info_label.visible = true

	if restart_button:
		restart_button.visible = true

	if next_level_button:
		next_level_button.visible = true

func _on_game_defeat() -> void:
	"""Display defeat message"""
	if info_label:
		info_label.text = "LEVEL FAILED!\n\nOut of shots!"
		info_label.modulate = Color.RED
		info_label.visible = true

	if restart_button:
		restart_button.visible = true

func _on_restart_pressed() -> void:
	"""Handle restart button press"""
	if game_manager and game_manager.has_method("restart_level"):
		game_manager.restart_level()

func _on_next_level_pressed() -> void:
	"""Handle next level button press"""
	# Get current scene name and extract level number
	var current_scene: String = get_tree().current_scene.scene_file_path
	var level_num: int = get_level_number(current_scene)

	# Load next level (or loop back to Level 1 if at Level 10)
	var next_level_num: int = level_num + 1
	if next_level_num > 10:
		next_level_num = 1

	var next_scene_path: String = "res://scenes/Level%d.tscn" % next_level_num
	if next_level_num == 1:
		next_scene_path = "res://scenes/TestLevel.tscn"  # Level 1 is TestLevel

	get_tree().change_scene_to_file(next_scene_path)

func get_level_number(scene_path: String) -> int:
	"""Extract level number from scene path"""
	if "TestLevel" in scene_path:
		return 1
	elif "Level" in scene_path:
		# Extract number from "Level2.tscn", "Level3.tscn", etc.
		var regex = RegEx.new()
		regex.compile("Level(\\d+)")
		var result = regex.search(scene_path)
		if result:
			return int(result.get_string(1))
	return 1
