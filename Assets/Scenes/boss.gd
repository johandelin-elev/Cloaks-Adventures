extends CharacterBody2D

enum State {IDLE, CHASE, ATTACK, HURT, DEAD}
var state: State = State.IDLE

var player: CharacterBody2D = null

var health = 300
var max_Health = 300
var damage = 20

@export var move_speed := 150.0
@export var attack_range := 200.0
@export var stop_distance := 100.0
@export var vertical_reach := 150.0
@export var hit_frame := 11

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite.sprite_frames.set_animation_loop("hit", false)
	animated_sprite.sprite_frames.set_animation_loop("death", false)
	animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match state:
		State.IDLE:
			velocity.x = 0
			if player:
				change_state(State.CHASE)
		State.CHASE:
			chase_player()
		_:
			velocity.x = 0
	
	move_and_slide()

func chase_player() -> void:
	if not is_instance_valid(player):
		player = null
		change_state(State.IDLE)
		return
	
	var dx: float = player.global_position.x - global_position.x
	var dy: float = player.global_position.y - global_position.y
	
	animated_sprite.flip_h = dx < 0
	
	if absf(dx) <= attack_range and dy <= vertical_reach and attack_timer.is_stopped():
		velocity.x = 0
		change_state(State.ATTACK)
	elif absf(dx) > stop_distance:
		velocity.x = signf(dx) * move_speed
	else:
		velocity.x = 0

func change_state(new_state: State) -> void:
	if state == State.DEAD:
		return
	
	state = new_state
	animated_sprite.stop()
	
	match new_state:
		State.IDLE, State.CHASE:
			animated_sprite.play("idle")
		State.ATTACK:
			animated_sprite.play("hit")
		State.HURT:
			animated_sprite.play("damaged")
		State.DEAD:
			animated_sprite.play("death")
			
func _on_animated_sprite_2d_frame_changed() -> void:
	if state != State.ATTACK:
		return
	if animated_sprite.animation != "hit" or animated_sprite.frame != hit_frame:
		return
	if not is_instance_valid(player):
		return
	
	var player_is_left = player.global_position.x < global_position.x
	if player_is_left != animated_sprite.flip_h:
		return
		
	var dx = absf(player.global_position.x - global_position.x)
	var dy = absf(player.global_position.y - global_position.y)
	if dx <= attack_range and dy <= vertical_reach:
		player.take_damage(damage)

func _on_animated_sprite_2d_animation_finished() -> void:
	var anim = animated_sprite.animation
	
	if anim == "hit":
		attack_timer.start()
		change_state(State.CHASE)
	elif anim == "damaged":
		change_state(State.CHASE)
	elif anim == "death":
		queue_free()
		
func take_damage(amount: int) -> void:
	if state == State.DEAD:
		return
	
	health = max(health - amount, 0)
	flash_red()
	
	if health == 0:
		die()
	elif state != State.ATTACK:
		change_state(State.HURT)

func flash_red() -> void:
	modulate = Color(1, 0.4, 0.4)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
func die() -> void:
	attack_timer.stop()
	$CollisionShape2D.set_deferred("disabled", true)
	change_state(State.DEAD)
	
func _on_area_2d_body_entered(body):
	if body.name == "Player" and player == null:
		player = body
	
func _on_area_2d_body_exited(body):
	if body == player:
		player = null
