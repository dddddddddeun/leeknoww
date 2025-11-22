extends CanvasLayer

@onready var quest_list: VBoxContainer = $PanelContainer/quest_list

func _ready():
	# QuestManager의 신호 연결
	QuestManager.quest_added.connect(_update_ui)
	QuestManager.quest_started.connect(_update_ui)
	QuestManager.quest_completed.connect(_update_ui)
	QuestManager.quests_loaded.connect(_update_ui)

	# 초기 업데이트
	_update_ui()


func _update_ui():
	# 기존 UI 제거
	for child in quest_list.get_children():
		child.queue_free()

	var quests = QuestManager.get_all_quests()

	# 퀘스트가 없으면 표시 X
	if quests.is_empty():
		return

	# 새 항목 추가
	for id in quests.keys():
		var q = quests[id]

		var label := Label.new()
		
		# 상태별 색상
		match q["status"]:
			"not_started":
				label.modulate = Color(1,1,1)          # 하얀색
			"in_progress":
				label.modulate = Color(0.7,0.9,1)      # 파란색
			"completed":
				label.modulate = Color(0.6,1,0.6)      # 초록색

		# 텍스트 구성
		label.text = "%s: %s" % [q["name"], q["status"]]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		
		quest_list.add_child(label)
