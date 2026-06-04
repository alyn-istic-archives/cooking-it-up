extends CharacterBody2D


var speed = 50
var player = null
var player_chase = false
var health = 100
var player_in_range = false
var taking_damage = true

signal enemy_died(enemy_position: Vector2)

func _physics_process(_delta):
	damage_dealt()
	if player_chase and is_instance_valid(player):
		var dir = (player.position-position).normalized()
		velocity = dir*speed
		$AnimatedSprite2D.play("walk")
		if(player.position.x - position.x)<0:
			$AnimatedSprite2D.flip_h=true
		else:
			$AnimatedSprite2D.flip_h=false
	else:
		velocity = Vector2.ZERO
	move_and_slide()
		
func enemy():
	pass

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_chase = true
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_chase = false
		player = null

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = true
		print("player in")
	else:
		pass
		
func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = false
		print("player left")
	else:
		pass

func damage_dealt():
	if player_in_range and global.player_atk_rn and taking_damage == true:
		health-=20
		$hurt_cooldown.start()
		taking_damage = false
		print("slime health =", health)
		if health <= 0:
			die()

func _on_hurt_cooldown_timeout() -> void:
	taking_damage = true;

func die():
	print("enemy: bleh")
	signalBus.enemy_died.emit()
	queue_free()
	
