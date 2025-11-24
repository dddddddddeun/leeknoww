extends Area2D

@export var item_data: ItemData= preload("res://items/Shovel_item.tres")        # 줍게 될 아이템 리소스

var player_in_range: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("pickup"):
		if item_data != null:
			Inventory.add_item(item_data)
		queue_free()  # 맵에서 사라지기
