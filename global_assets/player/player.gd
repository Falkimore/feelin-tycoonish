class_name Player
extends CharacterBody2D

# these are const variables, these cant be modified after the game starts.
# they are usually denoted with CAPITALS
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DASH_SPEED = 1200.0

var dashtimer = 0
var candash = false

# these are on ready variables, these get set when the object is created
# the dollar sign means its getting a child node, think of it like a relative file path
@onready var head: Sprite2D = $Head 

var spawn_pos: Vector2

# this is for the hat stacking code
@onready var hat_stack_start: Node2D = $Head/Hats
@onready var hat_top: Sprite2D = null

# runs when the player is created
func _ready() -> void:
	spawn_pos = position # set the spawn pos to the players default position
	
	Game.player = self # sets the global player variable to this node
	
	Game.player_died.connect(_respawn_player)
	Game.buyable_bought.connect(func ():
		if "dash" in Game.buyable_bought_list:
			candash = true
	)

# if you're confused what "delta" means here:
# https://www.reddit.com/r/gamedev/comments/p1tm4/super_newbish_questionwhat_is_delta_time_how_does/
func _physics_process(delta: float) -> void:
	dashtimer -= delta
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
		var hat = Sprite2D.new()
		hat.texture = load("res://global_assets/player/hats/tophat.svg")
		add_hat(hat)
	
	if Input.is_action_just_pressed("player_dash") and dashtimer <= 0 and candash:
		$squueueuee.play()
		dashtimer = 0.5
		velocity = (get_global_mouse_position() - position).normalized() * DASH_SPEED
		remove_all_hats()
	
	var direction := Input.get_axis("player_left", "player_right") # gets a value between -1 and 1
	if dashtimer > 0.25:
		# this is bugged but too funny to fix
		rotation = Time.get_ticks_msec() % 360
	else:
		rotation = move_toward(rotation, 0, 100)
		if direction != 0: # if its not 0 (aka we're moving)
			velocity.x = direction * SPEED
		else: # if we arent pressing anything
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# handles all the collision math for us, how nice!
	move_and_slide()
	
	#region Head Rotation
	# this is the head rotation code.
	# its its a load a gunk, so try not to worry about it
	# contact me if you need any help with it though
	
	head.rotation = 0
	head.look_at(get_global_mouse_position() - head.offset * 0.5)
	
	if head.rotation_degrees > 25.0 && head.rotation_degrees < 90.0:
		head.rotation_degrees = 25.0 
	elif head.rotation_degrees < 160.0 && head.rotation_degrees > 90.0:
		head.rotation_degrees = 160.0 
	
	if head.rotation_degrees < -90.0 || head.rotation_degrees > 90.0:
		head.scale.x = 0.5
		head.rotation_degrees += 180
	else:
		head.scale.x = -0.5
	#endregion

func add_hat(hat: Sprite2D) -> Sprite2D:
	if hat_top == null:
		hat_stack_start.add_child(hat)
		hat.position.y = hat.texture.get_height() * -0.5
	else:
		hat_top.add_child(hat)
		hat.position.y = -hat_top.texture.get_height() * hat_top.scale.y
	
	hat.position.x = 0
	hat_top = hat

	return hat

func remove_all_hats():
	for hat in hat_stack_start.get_children():
		hat.queue_free()
	hat_top = null

func _respawn_player():
	position = spawn_pos
