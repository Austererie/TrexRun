extends Node

#preload obstacles 
var bush_1 = preload("res://scenes/bush_1.tscn")
var rock_1 = preload("res://scenes/rock_1.tscn")
var rino = preload("res://scenes/rino.tscn")
var obstacle_types := [bush_1, rock_1]
var obstacles : Array


const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var score: int
const SCORE_MODIFIER : int = 100
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000
var screen_size : Vector2i
var ground_height: int
var game_running: bool
var last_obstacle


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $ground.get_node("Sprite2D").texture.get_height()

func new_game():
	#reset vars
	score = 0
	show_score()
	game_running = false
	
	#reset nodes
	$trex.position = DINO_START_POS
	$trex.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$ground.position = Vector2i(0, 0)
	
	$scoreCanvas.get_node("pressPlay").show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		
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
	if obstacles.is_empty():
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		obs = obs_type.instantiate()
		var obs_height = obs.get_node("Sprite2D").texture.get_height()
		var obs_scale = obs.get_node("Sprite2D").scale
		var obs_x : int = screen_size.x + score + 100
		var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 5)
		last_obstacle = obs
		
		add_obstacles(obs, obs_x, obs_y)
		
func add_obstacles(obs, x, y):
	obs.position = Vector2i(x, y)
	add_child(obs)
	obstacles.append(obs)
	
func show_score():
	$scoreCanvas.get_node("score").text = "Score: " + str(score / SCORE_MODIFIER)
