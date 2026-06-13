extends Label


signal timeout
var time_left: int = 90

@onready var timer: Timer = $Timer


func start_timer(time_seconds: int) -> void:
	time_left = time_seconds
	timer.start()
	timer.timeout.connect(_on_timer_timeout)


func stop_timer() -> void:
	timer.stop()
	visible = false


func _on_timer_timeout() -> void:
	time_left -= 1
	@warning_ignore("integer_division") var time_left_min = int(time_left/60)
	var time_left_sec = time_left - time_left_min*60
	text = "Time left : %d'%d''" % [time_left_min, time_left_sec]
	
	if time_left == 0:
		timeout.emit()
		timer.stop()
		visible = false
