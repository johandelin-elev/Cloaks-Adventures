extends Node2D

@onready var menu_camera: Camera2D = $MenuCamera
@onready var player_camera: Camera2D = $Player/Player/PlayerCamera

@onready var exploration_music: AudioStreamPlayer2D = $Exploration_Music
@onready var animated_sprite = $GameUI/EndScreen/AnimatedSprite2D
@onready var endscreen = $GameUI/EndScreen

var transition_started = false
var normal_zoom = Vector2(1, 1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	$GameUI/TransitionFade.modulate.a = 0.0
	$GameUI/EndScreen.hide()
	
func start_game() -> void:
	if transition_started:
		return

	transition_started = true

	var fade = $GameUI/TransitionFade
	var menu = $GameUI/MainMenu
	
	# Fade out the buttons individually.
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	tween.parallel().tween_property(
		menu.get_node("VBoxContainer/MainMenu_Start"),
		"modulate:a",
		0.0,
		1.0
	)

	tween.parallel().tween_property(
		menu.get_node("VBoxContainer/MainMenu_Quit"),
		"modulate:a",
		0.0,
		1.0
	)

	await tween.finished

	# Zoom and fade to black simultaneously.
	var background = menu.get_node("VBoxContainer_BG")

	var transition_tween = create_tween()
	transition_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	transition_tween.set_parallel(true)

	# Zoom the background.
	var zoom = transition_tween.tween_property(
		background,
		"scale",
		Vector2(2.0, 2.0),
		3.0
	)
	zoom.set_trans(Tween.TRANS_SINE)
	zoom.set_ease(Tween.EASE_IN_OUT)

	# Fade to black during the zoom.
	var fade_tween = transition_tween.tween_property(
		fade,
		"modulate:a",
		1.0,
		3.0
	)
	fade_tween.set_trans(Tween.TRANS_SINE)
	fade_tween.set_ease(Tween.EASE_IN_OUT)

	await transition_tween.finished

	# 5. Hide the menu and restore gameplay.
	menu.hide()
	menu_camera.enabled = false
	player_camera.enabled = true
	player_camera.make_current()

	get_tree().paused = false

	# 6. Fade into the level.
	tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade, "modulate:a", 0.0, 1.5)
	await tween.finished
	
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	exploration_music.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_menu_start_pressed() -> void:
	print("PLAY BUTTON PRESSED")
	start_game()


func _on_main_menu_quit_pressed() -> void:
	get_tree().quit()


func _on_death_menu_button_pressed() -> void:
	endscreen.show()
	animated_sprite.play("end_text")
	
	await animated_sprite.animation_finished
	await get_tree().create_timer(3.0).timeout #3 Sec delay
	get_tree().quit()


func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
