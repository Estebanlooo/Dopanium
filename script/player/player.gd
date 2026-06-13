class_name Player
extends CharacterBody2D


var speed: float = 125
var level: Level

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	level = get_tree().current_scene
	level.level_state_changed.connect(_on_level_state_changed)


func _physics_process(_delta: float) -> void:
	if level.current_state == Level.State.SELECT:
		look_at(get_global_mouse_position())
	
	if level.current_state == Level.State.HACKING:
		if level.current_enemy:
			look_at(level.current_enemy.global_position)
	
	if level.current_state == Level.State.SLICK:
		look_at(get_global_mouse_position())
		var direction = Input.get_vector("left", "right", "up", "down").normalized()
		velocity = direction * speed
		move_and_slide()
		
		if direction:
			sprite.play("walk")
		else:
			sprite.play("idle")


func die() -> void:
	sprite.play("die")


func _on_level_state_changed(new_state: Level.State) -> void:
	if new_state == Level.State.SELECT:
		sprite.play("idle")
	elif new_state == Level.State.HACKING:
		sprite.play("hack")
