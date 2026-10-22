extends RigidBody2D

var player: CharacterBody2D = null

var is_dead = false
var is_attacking = false
var attack_interrupted = false
var player_in_range = false

var health = 300
var max_Health = 300
var damage = 20

@export var move_speed = 150.0
@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lock_rotation = true
	animated_sprite.play("idle")
	$AttackTimer.start()

func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	if not is_instance_valid(player):
		player = null
		linear_velocity.x = 0
		return
	
	var distance = absf(player.global_position.x - global_position.x)
	
	if distance > 100:
		linear_velocity.x = sign(player.global_position.x - global_position.x) * move_speed
	else:
		linear_velocity.x = 0

	animated_sprite.flip_h = player.global_position.x < global_position.x

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player = body
		player_in_range = true

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player_in_range = false

func take_damage(amount: int) -> void:
	if is_dead:
		return
	
	attack_interrupted = true
	health -= amount
	health = max(health, 0)
	
	if health <= 0:
		die()
		return
	
	animated_sprite.play("damaged")
	await animated_sprite.animation_finished
	
	if is_dead:
		return
	
	attack_interrupted = false
	animated_sprite.play("idle")

func _on_attack_timer_timeout() -> void:
	if is_dead or attack_interrupted or is_attacking:
		return

	if not is_instance_valid(player):
		return
		
	var horizontal_distance = absf(player.global_position.x - global_position.x)
	var vertical_distance = absf(player.global_position.y - global_position.y)
	
	if horizontal_distance > 200 or vertical_distance > 70:
		return
	
	is_attacking = true
	animated_sprite.play("hit")
	player.take_damage(damage)
	
	await animated_sprite.animation_finished
	
	if is_dead:
		return
		
	is_attacking = false
	animated_sprite.play("idle")

func die() -> void:
	if is_dead:
		return
		
	is_dead = true
	$AttackTimer.stop()
	animated_sprite.stop()
	animated_sprite.sprite_frames.set_animation_loop("death", false)
	animated_sprite.play("death")
	
	await animated_sprite.animation_finished
	queue_free()
