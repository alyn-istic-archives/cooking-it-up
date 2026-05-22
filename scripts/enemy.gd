extends CharacterBody2D


var speed = 50
var player = null
var player_chase = false
var health = 100
var player_in_range = false

func _physics_process(delta):
	if player_chase and (player):
		position += (player.position-position).normalized() * speed * delta
		move_and_collide(Vector2(0,0))
		$AnimatedSprite2D.play("walk")
		
		if(player.position.x - position.x)<0:
			$AnimatedSprite2D.flip_h=true
		else:
			$AnimatedSprite2D.flip_h=false
		
func enemy():
	pass

func _on_detection_area_body_entered(body: Node2D) -> void:
	player_chase = true
	player = body

func _on_detection_area_body_exited() -> void:
	player_chase = false
	player = null



func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = true
		print("player in")
		
func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = false
		print("player left")

func player_attack():
	if player_in_range:
		health -= 20
		$cooldown.start()
		print(health)

func damage_dealt():
	if player_in_range and global.player_atk_rn ==True:
		health-=20
