extends CharacterBody2D
#
#
#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
#
#
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
	

var direction = "none"
var enemy_in_range = false
var atk_cooldown = true
var health = 100
var alive = true

const speed = 200

func ready():
	$AnimatedSprite2D.play("front_idle")

func player():
	pass

func _physics_process(delta):
	player_movement(delta)
	enemy_attack()
	if health <=0:
		health = 0
		print("pk")
		alive=false
		self.queue_free()
func player_movement(delta):
	if (Input.is_action_pressed("ui_right")):
		play_anim(1)
		direction = "right"
		velocity.x = speed
		velocity.y = 0
	elif (Input.is_action_pressed("ui_left")):
		play_anim(1)
		direction = "left"
		velocity.x = -speed
		velocity.y = 0
	elif (Input.is_action_pressed("ui_up")):
		play_anim(1)
		direction = "up"
		velocity.x = 0
		velocity.y = -speed
	elif (Input.is_action_pressed("ui_down")):
		play_anim(1)
		direction = "down"
		velocity.x = 0
		velocity.y = speed
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y= 0
	move_and_slide();
func play_anim(movement):
	var dir = direction
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h=true
		match movement:
			1:
				anim.play("side_walk")
			0:
				anim.play("side_idle")
	if dir == "left":
		anim.flip_h=false
		match movement:
			1:
				anim.play("side_walk")
			0:
				anim.play("side_idle")
	if dir == "up":
		match movement:
			1:
				anim.play("back_walk")
			0:
				anim.play("front_idle")
	if dir == "down":
		match movement:
			1:
				anim.play("front_walk")
			0:
				anim.play("front_idle")

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_range = true
		print("enemy in")
		
func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_range = false
		print("enemy left")

func enemy_attack():
	if enemy_in_range and atk_cooldown == true:
		health -= 20
		atk_cooldown = false
		$cooldown.start()
		print(health)


func _on_cooldown_timeout() -> void:
	atk_cooldown= true
