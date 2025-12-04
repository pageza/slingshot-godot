extends CanvasLayer
class_name HUD

## HUD for displaying game information
## Shows shots remaining, level progress, and game state

# === NODE REFERENCES ===
@onready var shots_label: Label = $ShotsLabel
@onready var info_label: Label = $InfoLabel
@onready var restart_button: Button = $RestartButton

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

	# Connect restart button
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
		restart_button.visible = false

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
