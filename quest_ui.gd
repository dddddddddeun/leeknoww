extends CanvasLayer

var quest_list: VBoxContainer = null

func _ready():
	_find_list_node()

	await get_tree().process_frame  # 첫 프레임 기다리기
	_update_ui()

	QuestManager.quest_added.connect(_update_ui)
	QuestManager.quest_started.connect(_update_ui)
	QuestManager.quest_completed.connect(_update_ui)
	QuestManager.quests_loaded.connect(_update_ui)



func _find_list_node():
	# PanelContainer/quest_list 찾기
	if has_node("PanelContainer/quest_list"):
		quest_list = get_node("PanelContainer/quest_list")
		print("[QuestUI] Loaded quest_list from PanelContainer/quest_list")
		return

	# Panel/QuestList 찾기
	if has_node("Panel/QuestList"):
		quest_list = get_node("Panel/QuestList")
		print("[QuestUI] Loaded quest_list from Panel/QuestList")
		return

	print("[QuestUI] ERROR: QuestList 노드를 찾지 못함")

func _update_ui():
	if quest_list == null:
		return

	for child in quest_list.get_children():
		child.queue_free()

	var quests = QuestManager.get_all_quests()

	for id in quests.keys():
		var q = quests[id]

		var label := Label.new()

		match q["status"]:
			"not_started":
				label.modulate = Color(1, 1, 1)

			"completed":
				label.modulate = Color(0.6, 1, 0.6)

		label.text = "%s: %s" % [q["name"], q["status"]]
		quest_list.add_child(label)
