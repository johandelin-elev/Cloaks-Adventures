extends CharacterBody2D

#Jump
const SPEED = 300.0
const JUMP_VELOCITY = -600.0
var can_Jump = true

#Dash
const DASH_VELOCITY = 1400
const dash_Timer = 1
var can_Dash = true


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and can_Jump and is_on_floor():
		can_Jump = false
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_released("ui_accept") and not is_on_floor():
		if can_Jump == false: #Ensures no jumping in air.
			velocity.y = 0
			can_Jump = true
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var movement_direction := Input.get_axis("ui_left", "ui_right")
	if Input.is_key_pressed(KEY_C):
		velocity.x = movement_direction * DASH_VELOCITY
	else:
		velocity.x = move_toward(velocity.x, 0, DASH_VELOCITY)
	
	if movement_direction and not Input.is_key_pressed((KEY_C)):
		velocity.x = movement_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
