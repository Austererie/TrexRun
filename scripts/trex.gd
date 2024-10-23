extends CharacterBody2D

const GRAVITY: int = 3800
const JUMP_SPEED: int = -1400

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		$runColiision.disabled = false
		if Input.is_action_pressed("ui_accept"):
			velocity.y = JUMP_SPEED
			$jumpSound.play()
		elif Input.is_action_pressed("ui_down"):
			$AnimatedSprite2D.play("duck")
			$runColiision.disabled = true
		else:
			$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("jump")
		
			
			
	move_and_slide()
	
