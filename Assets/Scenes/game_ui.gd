
extends CanvasLayer

@onready var death_screen = $DeathScreen
@onready var pause_menu = $PauseMenu

var is_paused = false
var is_dead = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	death_screen.hide()
	pause_menu.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not is_dead:
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	is_paused = not is_paused
	pause_menu.visible = is_paused
	get_tree().paused = is_paused

func show_death_screen() -> void:
	is_dead = true
	is_paused = false
	get_tree().paused = true
	pause_menu.hide()
	death_screen.show()

func _on_pause_menu_resume_pressed() -> void:
	toggle_pause()


func _on_pause_menu_quit_pressed() -> void:
	get_tree().quit()


func _on_retry_button_pressed() -> void:
	pass # Replace with function body.


func _on_death_menu_button_pressed() -> void:
	pass # Replace with function body.
