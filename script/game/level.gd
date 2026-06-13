class_name Level
extends Node2D


@export var time_seconds: int = 90
@export var hacks: Dictionary[Hack, int] = {
	Hack.SHOOT: 3,
	Hack.KILL_SELF: 1,
}

signal level_state_changed(new_state: State)
enum State {SELECT, HACKING, SLICK, END}
enum Hack {SHOOT, KILL_SELF}
var current_state: State = State.SELECT: set = _set_state
var current_enemy: Enemy
var instructions = {}
var timer: Node
var frame_count: int = 0

@onready var enemies := get_tree().get_nodes_in_group("enemies")
@onready var camera: Camera = get_tree().get_first_node_in_group("camera")
@onready var player: Player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	get_tree().get_first_node_in_group("cursor").enemy_selected.connect(_on_enemy_selected)
	
	timer = get_tree().get_first_node_in_group("ui_timer")
	timer.timeout.connect(_on_timer_timeout)
	timer.start_timer(time_seconds)
	
	_update_hacks_ui()


func _physics_process(_delta: float) -> void:
	# Enregistrement des instructions pour l'ennemi sélectionné
	if current_state == State.HACKING and current_enemy != null:
		var shoot = 0
		if current_enemy.current_state == Enemy.State.SHOOT: # Evite des doublons clic ennemi / shoot à la frame 0
			shoot = 1
		var kill_self = 0
		if current_enemy.current_state == Enemy.State.KILL_SELF:
			kill_self = 1
		instructions[current_enemy].append({
			"position": current_enemy.global_position,
			"rotation": current_enemy.global_rotation,
			"shoot": shoot,
			"kill_self": kill_self,
		})
	
	elif current_state == State.SLICK:
		frame_count += 1


func _process(_delta: float) -> void:
	# Conditions de fin de partie
	if current_state == State.SLICK:
		var finished = 0
		for enemy in instructions.keys():
			if frame_count > len(instructions[enemy]):
				finished += 1
		# Si tous les ennemis ont finis leurs instructions
		if finished == len(instructions.keys()):
			current_state = State.END


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("next"):
		if current_state == State.SELECT: # On revient à la sélection
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


func use_hack(hack: Hack) -> bool:
	if hacks[hack] == 0:
		return false
	else:
		hacks[hack] = clamp(hacks[hack]-1, 0, 99)
		_update_hacks_ui()
		return true


func _update_hacks_ui() -> void:
	var ui_hacks = get_tree().get_nodes_in_group("ui_hacks")
	ui_hacks[0].get_child(1).text = str(hacks[Hack.SHOOT])
	ui_hacks[1].get_child(1).text = str(hacks[Hack.KILL_SELF])


func _set_state(new_state: State) -> void:
	if new_state == State.HACKING:
		camera.track(current_enemy)
	elif new_state == State.SLICK:
		camera.track(player)
		frame_count = 0
	elif new_state == State.END:
		_end_level()
	else:
		camera.untrack()
	current_state = new_state
	level_state_changed.emit(new_state)


func _end_level() -> void:
	var enemy_still_alive: bool = false
	for enemy: Enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.current_state != Enemy.State.KILL_SELF && enemy.current_state != Enemy.State.DEAD:
			enemy_still_alive = true
			
	if enemy_still_alive: # Perdu
		player.die()
		get_tree().create_timer(1.5).timeout.connect(get_tree().get_first_node_in_group("ui_end_menu").get_child(0).enable)
	else: # Gagné
		get_tree().create_timer(1.5).timeout.connect(get_tree().get_first_node_in_group("ui_end_menu").get_child(1).enable)


func _on_enemy_selected(enemy: Enemy) -> void:
	if current_state == State.SELECT:
		current_enemy = enemy
		current_enemy.hack()
		instructions[current_enemy] = []
		current_state = State.HACKING


func _on_timer_timeout() -> void:
	if current_state == State.SELECT or current_state == State.HACKING:
		if current_state == State.HACKING: # On revient à la sélection si besoin
			current_state = State.SELECT
			current_enemy.unhack()
			current_enemy = null
		slick() # On passe en phase slick
