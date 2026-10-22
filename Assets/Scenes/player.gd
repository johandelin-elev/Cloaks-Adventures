extends CharacterBody2D

#Health
var health = 100
var max_health = 100

#Attack
var is_Attacking = false
var  attack_damage = 25

#Jump
const JUMP_VELOCITY = -1200
const SPEED = 600
var can_Jump = true

#Dash
const DASH_VELOCITY = 2200
const MAX_DASH_UP_VELOCITY = -800
var is_Dashing = false
var can_Dash = true
var dash_Time = 0.25
var dash_Timer = 0.0

var is_dead = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var health_bar = $health_overlay/AnimatedSprite2D
@onready var attack_area = $AttackArea

#PHYSICS
func _physics_process(delta: float) -> void:
	gravity_handler(delta)
	jump_handler()
	movement_and_dash_handler(delta)
	attack_handler()
	move_and_slide()

#Gravity
func gravity_handler(delta: float) -> void:
	if not is_on_floor() and not is_Dashing:
		velocity += get_gravity() * (delta * 2)

#Handle Jump
func jump_handler() -> void:
	while Input.is_action_just_pressed("ui_accept") and can_Jump and is_on_floor():
		can_Jump = false
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_released("ui_accept"):
		if can_Jump == false: #Ensures no jumping in air.
			velocity.y = 0
			can_Jump = true
	
#Handle Dash
func movement_and_dash_handler(delta: float) -> void:
	var movement_horizontal_direction := Input.get_axis("ui_left","ui_right")
	var movement_vertical_direction := Input.get_axis("ui_up","ui_down")
	
	if Input.is_action_just_pressed("dash") and can_Dash:
		can_Dash = false
		is_Dashing = true
		dash_Timer = dash_Time
	
	if is_on_floor() and dash_Timer <= 0:
		can_Dash = true
	
	if is_Dashing:
		dash_Timer -= delta
		if dash_Timer <= 0:
			velocity.x = 0
			velocity += get_gravity() * delta
			is_Dashing = false
		
		
	if is_Dashing and not is_Attacking:
		animated_sprite.play("dash")
		
		if movement_horizontal_direction:
			velocity.x = movement_horizontal_direction * DASH_VELOCITY
		elif movement_vertical_direction:
			if movement_vertical_direction < 0:
				velocity.y = movement_vertical_direction * (DASH_VELOCITY / 2)
				animated_sprite.rotation = deg_to_rad(90)
				velocity.y = maxf(velocity.y, MAX_DASH_UP_VELOCITY)
			elif movement_vertical_direction > 0:
				velocity.y = movement_vertical_direction * DASH_VELOCITY
				animated_sprite.rotation = deg_to_rad(-90)
		else:
			velocity += get_gravity() * (delta * 2)
	
	if not is_Dashing and not is_Attacking:	
		animated_sprite.rotation = 0
		if movement_horizontal_direction:
			velocity.x = movement_horizontal_direction * SPEED
			animated_sprite.play("run")
			animated_sprite.flip_h = movement_horizontal_direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			animated_sprite.play("idle")
		
func attack_handler() -> void:
	if Input.is_action_just_pressed("attack") and not is_Attacking:
		is_Attacking = true
		animated_sprite.play("attack")
		
		for body in $AttackArea.get_overlapping_bodies():
			if body == self:
				continue
			
			if body.has_method("take_damage"):
				body.take_damage(20)
		
func update_health() -> void:
	var frame_count = health_bar.sprite_frames.get_frame_count("health_bar")
	health_bar.frame = round(
		(1.0 - float(health) / max_health) * (frame_count - 1)
	)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	
	health -= amount
	health = max(health, 0)
	
	update_health()
	
	if health <= 0:
		is_dead = true
		$"../../GameUI".show_death_screen()
		


func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_Attacking = false
