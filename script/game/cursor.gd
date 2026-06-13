class_name Cursor
extends Area2D


@export var in_game: bool = true

signal enemy_selected(enemy: Enemy)
signal position_changed(new_position: Vector2)
var target_enemy: Enemy
var sprite: AnimatedSprite2D

@onready var camera: Camera = get_tree().get_first_node_in_group("camera")


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = load("uid://5y525vdppc5b")
	sprite.z_index = 3
	sprite.play("default")
	if in_game:
		get_tree().get_first_node_in_group("ui").add_sibling.call_deferred(sprite)
	else:
		add_sibling.call_deferred(sprite)


func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	position_changed.emit(sprite.global_position)
	
	if target_enemy:
		var offset = (global_position - target_enemy.global_position) * 0.15
		set_sprite_target(target_enemy.global_position + offset)
		
		if Input.is_action_just_pressed("select"):
			enemy_selected.emit(target_enemy)
	else:
		set_sprite_target(global_position)


func set_sprite_target(pos: Vector2) -> void:
	var target: Vector2
	if in_game:
		target = pos + sprite.get_viewport_rect().size / 2 - camera.global_position
	else:
		target = pos
	sprite.global_position = lerp(sprite.global_position, target, 0.5)


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy and (get_tree().current_scene.current_state == Level.State.SELECT):
		target_enemy = body
		sprite.play("enemy")


func _on_body_exited(body: Node2D) -> void:
	if body == target_enemy:
		target_enemy = null
		sprite.play("default")
