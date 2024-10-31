extends Node

#preload obstacles 
var bush_1 = preload("res://scenes/bush_1.tscn")
var bush_2 = preload("res://scenes/bush_2.tscn")
var rock_1 = preload("res://scenes/rock_1.tscn")
var rock_2 = preload("res://scenes/rock_2.tscn")
var rino = preload("res://scenes/rino.tscn")
var obstacle_types := [bush_1, rock_1, bush_2, rock_2]
var obstacles : Array


const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var score: int
const SCORE_MODIFIER : int = 70
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000
var high_Score: int
var screen_size : Vector2i
var ground_height: int
var game_running: bool
var last_obstacle
var difficulty
const MAX_DIFFICULTY: int = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $ground.get_node("Sprite2D").texture.get_height()
	$gameOver.get_node("restartButton").pressed.connect(new_game)
	new_game()
	
func new_game():
	#reset vars
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
	#clear obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	
	#reset nodes
	$trex.position = DINO_START_POS
	$trex.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$ground.position = Vector2i(0, 0)
	
	$scoreCanvas.get_node("pressPlay").show()
	$gameOver.hide()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		#speed up and adjust dificulty 
		
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		#generate_obstacles
		generate_obstacles()
		
		#mov dino and camera
		$trex.position.x += speed
		$Camera2D.position.x += speed
		
		
		#update score
		score += speed
		show_score()
		
		#update ground position
		if $Camera2D.position.x - $ground.position.x > screen_size.x * 1.5:
			$ground.position.x += screen_size.x
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$scoreCanvas.get_node("pressPlay").hide()
			
		
func generate_obstacles():
	#ground obstacles
	if obstacles.is_empty() or last_obstacle.position.x < score + randi_range(50, 300):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1 
		for i in range (randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100+ (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 5)
			last_obstacle = obs
			add_obstacles(obs, obs_x, obs_y)
			
		#randomly spawn the rino
		#if difficulty == 0: #MAX_DIFFICULTY:
			#if (randi() % 2) == 0:
				#obs = rino.instantiate()
				#var obs_x : int = screen_size.x + score + 100
				#var rino_height = obs.get_node("AnimatedSprite2D").frame.get_frame("run", 0).get_height()
				#var rino_scale = obs.get_nod("AnimatedSprite2D").frame.get_frame("run", 0).scale
				#var obs_y : int = screen_size.y - ground_height - (rino_height * rino_scale.y / 5)
				#add_obstacles(obs, obs_x, obs_y)
				
				
		
		
func add_obstacles(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func hit_obs(body):
	if body.name == "trex":
		game_over()
		
func game_over():
	get_tree().paused = true
	game_running = false
	$gameOver.show()
	set_high_score()
		
		
	
	
	
func show_score():
	$scoreCanvas.get_node("score").text = "Score: " + str(score / SCORE_MODIFIER)
	
func set_high_score():
	if score > high_Score:
		high_Score = score
		$scoreCanvas.get_node("highScore").text = "High Score: " + str(high_Score / SCORE_MODIFIER)
	
func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	
