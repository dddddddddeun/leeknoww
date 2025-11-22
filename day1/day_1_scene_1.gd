extends Node2D    # 또는 너의 최상위 노드 타입

@onready var day1_quests = load("res://quests/day1_quests.gd").new()

func _ready():
	print("Day1 quests loading...")
	print("Day1 scene loaded!")
	for q in day1_quests.quests:
		QuestManager.add_quest(q["id"], q["name"], q["desc"])
