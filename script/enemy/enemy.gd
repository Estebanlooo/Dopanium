class_name Enemy
extends CharacterBody2D


@export var speed: int = 100
@export var shoot_time: float = 1.5
@export var kill_self_time: float = 1.0

var hacked := false
var launched := false
var frame_counter: int = 0
var instructions: Array
enum State {DEFAULT, SHOOT, KILL_SELF, DEAD}
var current_state: State = State.DEFAULT: set = _set_state

var real_ennemy_sprite: Sprite2D # On place un sprite pour simuler que l'ennemi réel reste à sa place

var level: Level

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_frames: SpriteFrames = preload("uid://cgi7q7dfjomja")
@onready var texture: Texture2D = preload("uid://cdhs3kdvb2ct6")


func _ready() -> void:
	level = get_tree().current_scene
	
	sprite.sprite_frames = sprite_frames
	get_tree().current_scene.level_state_changed.connect(_on_level_state_changed)


func _physics_process(_delta: float) -> void:
	# Phase de hacking, ennemi sélectionné
	if hacked:
		var x_dir = Input.get_axis("left", "right")
		var y_dir = Input.get_axis("up", "down")
		var direction = Vector2(x_dir, y_dir).normalized()
		
		if current_state == State.DEFAULT:
			
			if Input.is_action_just_pressed("next"):
				level.stop_hacking()
			
			if direction:
				sprite.play("walk")
			else:
				sprite.play("idle")
			
			if Input.is_action_just_pressed("shoot") and level.use_hack(Level.Hack.SHOOT):
				current_state = State.SHOOT
			elif Input.is_action_just_pressed("kill_self") and level.use_hack(Level.Hack.KILL_SELF):
				current_state = State.KILL_SELF
				
			look_at(get_global_mouse_position())
			velocity = direction * speed
			
		else:
			velocity = Vector2.ZERO
		move_and_slide()
		
	# Phase slick
	elif launched:
		if frame_counter < len(instructions):
			var ins = instructions[frame_counter]
			frame_counter += 1
			
			if current_state == State.DEFAULT:
				if global_rotation != ins["rotation"]:
					sprite.play("walk")
				else:
					sprite.play("idle")
				
				if ins["shoot"]:
					current_state = State.SHOOT
				elif ins["kill_self"]:
					current_state = State.KILL_SELF
					
			elif current_state == State.SHOOT:
				var object_in_sight: Object = _get_line_of_sight()
				if object_in_sight is Enemy:
					if object_in_sight.current_state != State.DEAD:
						object_in_sight.kill()
				elif object_in_sight is Player:
					# Tue le joueur => fin du niveau
					level.current_state = Level.State.END
			
			global_rotation = ins["rotation"]
			global_position = ins["position"]


func kill() -> void:
	current_state = State.DEAD


func hack() -> void: # Une fois sélectionné par le joueur
	set_collision_layer_value(1, false) # Empêche qu'il soit sélectionné par le curseur
	hacked = true
	current_state = State.DEFAULT
	modulate = Color("28dcf795")
	 # Place un même sprite à sa position 
	real_ennemy_sprite = Sprite2D.new()
	real_ennemy_sprite.texture = texture
	real_ennemy_sprite.offset = sprite.offset
	real_ennemy_sprite.modulate = Color(1,1,1,1)
	real_ennemy_sprite.global_transform = global_transform
	add_sibling(real_ennemy_sprite)


func unhack() -> void: # Déselectionné par le joueur
	set_collision_layer_value(1, true)
	hacked = false
	sprite.play("idle")
	current_state = State.DEFAULT
	modulate = Color(1,1,1,1)
	global_transform = real_ennemy_sprite.global_transform # Revient à la position initiale
	real_ennemy_sprite.queue_free() # Supprime le sprite doublon
	

func launch(instructions_list: Array = []) -> void: # Lance l'ennemi dans la phase slick du niveau
	instructions = instructions_list
	frame_counter = 0
	launched = true


func _get_line_of_sight() -> Node:
	var space_state = get_world_2d().direct_space_state
	var direction = Vector2.from_angle(global_rotation)
	var query = PhysicsRayQueryParameters2D.create(global_position+direction*20, global_position+direction*500)
	var result = space_state.intersect_ray(query)
	if result:
		return result["collider"]
	else:
		return null

	
func _set_state(new_state: State) -> void:
	if new_state == State.SHOOT:
		get_tree().create_timer(shoot_time).timeout.connect(_on_shoot_timeout)
		sprite.play("shoot")
	elif new_state == State.KILL_SELF:
		get_tree().create_timer(kill_self_time).timeout.connect(_on_kill_self_timeout)
		sprite.play("kill_self")
	elif new_state == State.DEAD:
		get_tree().create_timer(1.0).timeout.connect(queue_free)
		sprite.play("die")
	current_state = new_state


func _on_shoot_timeout() -> void:
	current_state = State.DEFAULT
	
	
func _on_kill_self_timeout() -> void:
	if hacked:
		level.stop_hacking()
	elif launched:
		kill()


func _on_level_state_changed(new_state: Level.State) -> void:
	if new_state == Level.State.HACKING:
		if not hacked:
			sprite.pause()
	else:
		sprite.play()
