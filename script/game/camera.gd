class_name Camera
extends Camera2D


var tracked_object: Node2D


func _process(_delta: float) -> void:
	var target
	if tracked_object:
		target = tracked_object.global_position
	else:
		target = Vector2.ZERO
	global_position = lerp(global_position, target, 0.15)


func track(object: Node2D) -> void:
	tracked_object = object


func untrack() -> void:
	tracked_object = null
