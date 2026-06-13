extends Label


var dialogues = [
	"Come on Plati, breathe. This is it. The base is right there...",
	"I'll use my Cursor to scan the perimeter. No need to expose myself, I'm just checking who's out there.",
	"As soon as I see a target, a Left Click and I hack their processor. Once I'm in, I pilot them with W, A, S, D.", 
	"I'll use Left Click to empty their mags on their buddies. And if I'm stuck: Right Click, I'll overload the battery and self-destruct.",
	"If I dawdle too long, the hack fails. And I don't have infinite ammo: my Red Keys for shots and my Yellow Keys for explosions are limited.",
	"The goal is simple: no robot left standing. Let's go."
]

var index = 0

func _ready():
	text = dialogues[index]

func _input(event):
	if event.is_action_pressed("ui_accept"):
		passer_au_suivant()

func passer_au_suivant():
	index += 1
	
	if index < dialogues.size():
		text = dialogues[index]
	else:
		get_tree().change_scene_to_file("res://scene/game.tscn")
