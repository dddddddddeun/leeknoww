extends CanvasLayer

@onready var quest_list: VBoxContainer = null

func _ready():
	# 안전하게 노드 찾기
	if has_node("Panel/QuestList"):
		quest_list = get_node("Panel/QuestList")
	else:
		print("[QuestUI] Panel/QuestList not found!")
		return

	# 신호 연결
	QuestManager.quest_added.connect(_update_ui)
	QuestManager.quest_started.connect(_update_ui)
	QuestManager.quest_completed.connect(_update_ui)
	QuestManager.quests_loaded.connect(_update_ui)

	_update_ui()


func _update_ui():
	if quest_list == null:
		return

	# 기존 UI 제거
	for child in quest_list.get_children():
		child.queue_free()

	var quests = QuestManager.get_all_quests()

	for id in quests.keys():
		var q = quests[id]

		if q["status"] == "not_started":
			continue

		var label := Label.new()

		if q["status"] == "completed":
			label.text = "🟢 " + q["name"]
			label.add_theme_color_override("font_color", Color.GRAY)
		else:
			label.text = "🔹 " + q["name"]

		quest_list.add_child(label)
