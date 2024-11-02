extends CharacterBody2D

var direction := Vector2.ZERO
@export var max_jumps = 1
@onready var jumps =  max_jumps
@export var SPEED = 150.0
@export var fric = 900.0
@export var accel = 450.0

@export var jump_height := 60.0
@export var jump_peak_time := 0.4
@export var jump_land_time := 0.5
@onready var jump_velocity : float = ((2.0 * jump_height) / jump_peak_time) * -1.0
@onready var jump_gravity : float = ((2.0 * jump_height) / (jump_peak_time * jump_peak_time))
@onready var fall_gravity : float = ((2.0 * jump_height) / (jump_land_time * jump_land_time))

func get_direction():
	return Vector2(
		Input.get_action_strength("right")-Input.get_action_strength("left"),
		Input.get_action_strength("down")-Input.get_action_strength("up")
	)

func calc_velo_x(dir, velo, delta):
	velo += dir.x * accel * delta
	velo = clamp(velo, -SPEED, +SPEED)
	if sign(dir.x) != sign(velo):
		velo = move_toward(velo, 0.0, delta * fric)
	return velo

func calc_velo_y(velo, delta):
	if Input.is_action_pressed("jump") and jumps > 0:
		if Input.is_action_just_pressed("jump") and not is_on_floor() and jumps > 1:
			if $Timers/CayoteTimer.is_stopped():
				jumps -= 1
			velo = jump_velocity
		elif is_on_floor():
			velo = jump_velocity
	elif Input.is_action_just_released("jump"):
		velo /= 2
	if velo < 0:
		velo += jump_gravity * delta
	else:
		velo += fall_gravity * delta
	velo = clamp(velo, -SPEED*5, +SPEED*5)
	return velo


func _physics_process(delta):
	direction = get_direction()
	#if direction.x != 0:
		#$Sprite2D.flip_h = direction.x < 0
	move_and_slide()
	if is_on_floor() :
		jumps = max_jumps
		if $Timers/CayoteTimer.is_stopped():
			$Timers/CayoteTimer.start()
	velocity.x = calc_velo_x(direction, velocity.x, delta)
	velocity.y = calc_velo_y(velocity.y, delta)
