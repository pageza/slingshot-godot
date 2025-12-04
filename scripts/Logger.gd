extends Node

## Global Logger singleton for comprehensive game event and error logging
## Automatically logs to file with timestamps for debugging crashes and issues

# === CONFIGURATION ===
const LOG_FILE_NAME: String = "game_log.txt"
const MAX_LOG_SIZE: int = 10485760  # 10MB max log size before rotation
const ENABLE_CONSOLE_MIRROR: bool = true  # Also print to console

# === LOG LEVELS ===
enum LogLevel {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

# === STATE ===
var log_file: FileAccess
var log_path: String
var session_start_time: float
var is_initialized: bool = false

func _ready() -> void:
	initialize_logger()
	log_info("=== GAME SESSION STARTED ===")
	log_info("Godot version: %s" % Engine.get_version_info().string)
	log_info("Platform: %s" % OS.get_name())
	log_info("Screen size: %s" % str(DisplayServer.screen_get_size()))

func initialize_logger() -> void:
	"""Initialize the logging system and open log file"""
	session_start_time = Time.get_unix_time_from_system()

	# Get user data directory
	var user_dir: String = OS.get_user_data_dir()
	log_path = user_dir + "/" + LOG_FILE_NAME

	# Check if log file exists and rotate if too large
	if FileAccess.file_exists(log_path):
		var existing_file = FileAccess.open(log_path, FileAccess.READ)
		if existing_file:
			var file_size = existing_file.get_length()
			existing_file.close()

			if file_size > MAX_LOG_SIZE:
				# Rotate: rename old log
				var backup_path = user_dir + "/game_log_old.txt"
				if FileAccess.file_exists(backup_path):
					DirAccess.remove_absolute(backup_path)
				DirAccess.rename_absolute(log_path, backup_path)

	# Open log file for writing (append mode)
	log_file = FileAccess.open(log_path, FileAccess.WRITE_READ)
	if log_file:
		log_file.seek_end()  # Append to end
		is_initialized = true
		_write_raw("\n\n" + "=".repeat(80))
		_write_raw("NEW SESSION: %s" % get_timestamp())
		_write_raw("=".repeat(80))
	else:
		push_error("Failed to open log file: %s" % log_path)
		is_initialized = false

func _notification(what: int) -> void:
	"""Ensure log file is closed on exit"""
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		log_info("=== GAME SESSION ENDED ===")
		close_logger()

func close_logger() -> void:
	"""Close the log file safely"""
	if log_file:
		log_file.flush()
		log_file.close()
		log_file = null
	is_initialized = false

func get_timestamp() -> String:
	"""Get formatted timestamp for log entries"""
	var datetime = Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d %02d:%02d:%02d" % [
		datetime.year, datetime.month, datetime.day,
		datetime.hour, datetime.minute, datetime.second
	]

func get_session_time() -> String:
	"""Get time elapsed since session start"""
	var elapsed = Time.get_unix_time_from_system() - session_start_time
	return "%.2f" % elapsed

func _write_raw(message: String) -> void:
	"""Write raw message to log file"""
	if not is_initialized or not log_file:
		return

	log_file.store_line(message)
	log_file.flush()  # Ensure it's written immediately

func _log(level: LogLevel, message: String, context: String = "") -> void:
	"""Internal logging function"""
	var level_str: String
	match level:
		LogLevel.DEBUG:
			level_str = "DEBUG"
		LogLevel.INFO:
			level_str = "INFO"
		LogLevel.WARNING:
			level_str = "WARN"
		LogLevel.ERROR:
			level_str = "ERROR"
		LogLevel.CRITICAL:
			level_str = "CRITICAL"
		_:
			level_str = "UNKNOWN"

	var context_str = (" [%s]" % context) if context != "" else ""
	var log_message = "[%s +%ss] %s%s: %s" % [
		get_timestamp(),
		get_session_time(),
		level_str,
		context_str,
		message
	]

	# Write to file
	_write_raw(log_message)

	# Mirror to console if enabled
	if ENABLE_CONSOLE_MIRROR:
		match level:
			LogLevel.ERROR, LogLevel.CRITICAL:
				push_error(message)
			LogLevel.WARNING:
				push_warning(message)
			_:
				print(log_message)

# === PUBLIC LOGGING METHODS ===

func log_debug(message: String, context: String = "") -> void:
	"""Log debug information"""
	_log(LogLevel.DEBUG, message, context)

func log_info(message: String, context: String = "") -> void:
	"""Log general information"""
	_log(LogLevel.INFO, message, context)

func log_warning(message: String, context: String = "") -> void:
	"""Log warnings"""
	_log(LogLevel.WARNING, message, context)

func log_error(message: String, context: String = "") -> void:
	"""Log errors"""
	_log(LogLevel.ERROR, message, context)

func log_critical(message: String, context: String = "") -> void:
	"""Log critical errors"""
	_log(LogLevel.CRITICAL, message, context)

# === SPECIALIZED LOGGING METHODS ===

func log_game_event(event: String, details: Dictionary = {}) -> void:
	"""Log important game events with structured data"""
	var message = "GAME EVENT: %s" % event
	if not details.is_empty():
		message += " | Data: %s" % JSON.stringify(details)
	log_info(message, "GameEvent")

func log_physics_event(event: String, body: Node = null, velocity: Vector2 = Vector2.ZERO) -> void:
	"""Log physics-related events"""
	var message = event
	if body:
		message += " | Body: %s" % body.name
	if velocity.length() > 0:
		message += " | Velocity: %.2f" % velocity.length()
	log_debug(message, "Physics")

func log_collision(body1: String, body2: String, impact_velocity: float = 0.0) -> void:
	"""Log collision events"""
	var message = "Collision: %s <-> %s" % [body1, body2]
	if impact_velocity > 0:
		message += " | Impact: %.2f" % impact_velocity
	log_debug(message, "Collision")

func log_damage(target: String, damage: float, health_remaining: float) -> void:
	"""Log damage events"""
	var message = "%s took %.1f damage | Health: %.1f" % [target, damage, health_remaining]
	log_info(message, "Damage")

func log_destruction(target: String, position: Vector2) -> void:
	"""Log object destruction"""
	var message = "%s destroyed at %s" % [target, position]
	log_info(message, "Destruction")

func log_projectile_launch(velocity: Vector2, position: Vector2) -> void:
	"""Log projectile launches"""
	var message = "Projectile launched | Vel: %.2f | Pos: %s" % [velocity.length(), position]
	log_info(message, "Projectile")

func log_level_event(event: String, level_name: String = "") -> void:
	"""Log level-related events"""
	var message = event
	if level_name != "":
		message += " | Level: %s" % level_name
	log_info(message, "Level")

# === UTILITY METHODS ===

func get_log_file_path() -> String:
	"""Get the full path to the log file"""
	return log_path

func print_log_location() -> void:
	"""Print log file location to console"""
	print("Game log location: %s" % log_path)
