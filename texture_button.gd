extends TextureButton

func _ready():
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	DayManager.change_day(1)
