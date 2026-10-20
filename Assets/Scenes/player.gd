extends CharacterBody2D

#Jump
const SPEED = 300.0
const JUMP_VELOCITY = -600.0
var can_Jump = true

#Dash
const DASH_VELOCITY = 1400
var can_Dash = true
var is_Dashing = false
var dash_Time = 0.15
var dash_Timer = 0.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not is_Dashing:
		velocity += get_gravity() * delta

	# Handle jump.
	while Input.is_action_just_pressed("ui_accept") and can_Jump and is_on_floor():
		can_Jump = false
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_released("ui_accept"):
		if can_Jump == false: #Ensures no jumping in air.
			velocity.y = 0
			can_Jump = true
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var movement_horizontal_direction := Input.get_axis("ui_left","ui_right")
	var movement_vertical_direction := Input.get_axis("ui_up","ui_down")
	
	if is_on_floor():
		can_Dash = true
	
	if Input.is_action_just_pressed("dash") and can_Dash:
		can_Dash = false
		is_Dashing = true
		dash_Timer = dash_Time
	
	if is_Dashing:
		if movement_horizontal_direction:
			velocity.x = movement_horizontal_direction * DASH_VELOCITY
		elif movement_vertical_direction:
			if movement_vertical_direction < 0:
				velocity.y = movement_vertical_direction * (DASH_VELOCITY / 2)
			elif movement_vertical_direction > 0:
				velocity.y = movement_vertical_direction * DASH_VELOCITY
		else:
			velocity += get_gravity() * delta
				
		dash_Timer -= delta
		if dash_Timer <= 0:
			velocity += get_gravity() * delta
			is_Dashing = false
	
	if movement_horizontal_direction and not is_Dashing:
		velocity.x = movement_horizontal_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
