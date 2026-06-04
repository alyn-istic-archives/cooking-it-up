extends CharacterBody2D


var direction = "none"
var enemy_in_range = false
var taking_damage = true
var health = 100
var alive = true
var atk_prog = false


const speed = 200


func player():
	pass

func _physics_process(_delta):
	player_movement(_delta)
	damage_dealt()
	player_attack()
	if health <=0:
		health = 0
		print("pk")
		alive=false
		self.queue_free()
func player_movement(_delta):
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
				if atk_prog == false:
					anim.play("side_idle")

	if dir == "left":
		anim.flip_h=false
		match movement:
			1:
				anim.play("side_walk")
			0:
				if atk_prog == false:
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
				if atk_prog == false:
					anim.play("front_idle")



func damage_dealt():
	if enemy_in_range == true and taking_damage == true:
		health -= 20
		taking_damage = false
		$dmg_dealt_cooldown.start()
		print(health)



func player_attack():
	var dir = direction
	
	if Input.is_action_just_pressed("attack"):
		global.player_atk_rn = true
		atk_prog = true
		print("attack?")
		match (dir):
			"right":
				$AnimatedSprite2D.flip_h=true;
				$AnimatedSprite2D.play("side_atk")
				$deal_atk_timer.start()
			"left":
				$AnimatedSprite2D.flip_h=false;
				$AnimatedSprite2D.play("side_atk")
				$deal_atk_timer.start()
			"down":
				$AnimatedSprite2D.play("front_atk")
				$deal_atk_timer.start()
			"up":
				$AnimatedSprite2D.play("front_atk")
				$deal_atk_timer.start()
				
	

func _on_deal_atk_timer_timeout() -> void:
	$deal_atk_timer.stop()
	global.player_atk_rn = false
	atk_prog = false
#
#


func _on_hitbox_area_shape_exited(body: Node2D) -> void:
	if (body.has_method("enemy")):
		print("enemy out")
		enemy_in_range = false # Replace with function body.
	else:
		pass


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_range = true




func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_in_range = false


func _on_dmg_dealt_cooldown_timeout() -> void:
	taking_damage = true
	damage_dealt()
