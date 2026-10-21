extends RigidBody2D

var player: CharacterBody2D = null

var is_dead = false
var player_in_range = false

var health = 200
var max_Health = 200
var damage = 20

@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite.play("idle")


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
		player = null
		
		if not is_dead:
			animated_sprite.play("idle")

func take_damage(amount: int) -> void:
	if is_dead:
		return
	
	health -= amount
	health = max(health, 0)
	
	if health <= 0:
		die()
		return
	
	animated_sprite.play("damaged")
	await animated_sprite.animation_finished
	
	if not is_dead and animated_sprite.animation == "damaged":
		animated_sprite.play("idle")

func _on_attack_timer_timeout() -> void:
	if is_dead or player == null:
		return

	if not is_instance_valid(player):
		player = null
		player_in_range = false
		return

	if not $Area2D.overlaps_body(player):
		player = null
		player_in_range = false
		return

	animated_sprite.play("hit")
	player.take_damage(damage)

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
