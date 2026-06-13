extends Node2D


@export var time_seconds: int = 90
@export var hacks: Dictionary[String, int] = {
	"shoot": 3,
	"kill_self": 1,
}

@onready var dopanium: AudioStreamPlayer = $dopanium
@onready var tir: AudioStreamPlayer = $tir

enum State {SELECT, HACKING, SLICK}
var current_state: State = State.SELECT
var current_enemy: Enemy
var instructions = {}
var timer: Node

@onready var enemies := get_tree().get_nodes_in_group("enemies")


func _ready() -> void:
	get_tree().get_first_node_in_group("cursor").enemy_selected.connect(_on_enemy_selected)
	timer = get_tree().get_first_node_in_group("timer")
	timer.timeout.connect(_on_timer_timeout)
	timer.start_timer(time_seconds)
	
	dopanium.play()


func _physics_process(_delta: float) -> void:
	# Enregistrement des instructions pour l'ennemi sélectionné
	if current_state == State.HACKING and current_enemy != null:
		var shoot = 0
		if Input.is_action_just_pressed("shoot") and len(instructions[current_enemy]) > 0: # Evite des doublons clic ennemi / shoot à la frame 0
			shoot = 1
		var kill_self = 0
		if Input.is_action_just_pressed("kill_self"):
			kill_self = 1
		instructions[current_enemy].append({
			"position": current_enemy.global_position,
			"rotation": current_enemy.global_rotation,
			"shoot": shoot,
			"kill_self": kill_self,
		})


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("next"):
		if current_state == State.HACKING: # On revient à la sélection
			stop_hacking()
		elif current_state == State.SELECT: # On passe en phase slick
			slick()
			
			
func stop_hacking() -> void:
	current_state = State.SELECT
	current_enemy.unhack()
	current_enemy = null


func slick() -> void:
	timer.stop_timer()
	current_state = State.SLICK
	for enemy in enemies:
		if instructions.keys().has(enemy):
			enemy.launch(instructions[enemy])
		else:
			enemy.launch()


func _on_enemy_selected(enemy: Enemy) -> void:
	if current_state == State.SELECT:
		current_state = State.HACKING
		current_enemy = enemy
		current_enemy.hack()
		instructions[current_enemy] = []


func _on_timer_timeout() -> void:
	if current_state == State.SELECT or current_state == State.HACKING:
		if current_state == State.HACKING: # On revient à la sélection si besoin
			current_state = State.SELECT
			current_enemy.unhack()
			current_enemy = null
		slick() # On passe en phase slick


func _on_dopanium_finished() -> void:
	dopanium.play()
