extends Label

@export var label_node: Label

func _ready():
	body_exited.connect(_on_body_exited)

func _on_body_exited(body):
	if body.name == "Player":
		label_node.visible = false
