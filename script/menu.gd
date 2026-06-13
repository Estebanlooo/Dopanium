extends Node2D

@onready var intr_2: AudioStreamPlayer2D = $intr2
@onready var lance: AudioStreamPlayer2D = $lance

var quelle := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_intr_2_finished() -> void:
	intr_2.play()

func _on_lance_finished() -> void:
	if quelle == 1:
		get_tree().change_scene_to_file("res://scene/tuto.tscn")

func _on__pressed() -> void:
	intr_2.stop()
	lance.play()
	quelle=1

func _on__pressed2() -> void:
	intr_2.stop()
	lance.play()
	quelle=2

func _on__pressed3() -> void:
	intr_2.stop()
	lance.play()
	quelle=3
