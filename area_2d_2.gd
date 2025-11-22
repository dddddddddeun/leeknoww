extends Area2D

@export var target_scene_path: String = "res://day1/day1_scene_2.tscn"
var player_in_area: bool = false

func _ready():
	$Label.visible = false

	# Godot 4 방식의 신호 연결
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_area = true
		$Label.visible = true


func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_area = false
		$Label.visible = false


func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file(target_scene_path)
