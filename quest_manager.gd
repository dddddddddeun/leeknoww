extends Node

# -------------------------
# Signals
# -------------------------
signal quest_added(id: String)
signal quest_started(id: String)
signal quest_completed(id: String)
signal quests_loaded()

# -------------------------
# Quests Dictionary
# quests = {
#   "quest_id": {
#       "name": String,
#       "desc": String,
#       "status": "not_started" | "in_progress" | "completed"
#   }
# }
# -------------------------
var quests: Dictionary = {}

# 자동 저장
var autosave: bool = true
var save_path: String = "user://quests.save"


# ==========================================================
# READY : 게임 시작 시 자동 로드
# ==========================================================
func _ready() -> void:
	load_quests()


# ==========================================================
# 퀘스트 추가
# ==========================================================
func add_quest(id: String, name: String, desc: String = "") -> void:
	if quests.has(id):
		push_warning("Quest already exists: %s" % id)
		return

	quests[id] = {
		"name": name,
		"desc": desc,
		"status": "not_started"
	}

	emit_signal("quest_added", id)

	if autosave:
		save_quests()


# ==========================================================
# 퀘스트 시작
# ==========================================================
func start_quest(id: String) -> void:
	if not quests.has(id):
		push_error("start_quest: Unknown quest ID: %s" % id)
		return

	var q: Dictionary = quests[id]

	if q["status"] == "not_started":
		q["status"] = "in_progress"
		quests[id] = q

		emit_signal("quest_started", id)

		if autosave:
			save_quests()


# ==========================================================
# 퀘스트 완료
# ==========================================================
func complete_quest(id: String) -> void:
	if not quests.has(id):
		push_error("complete_quest: Unknown quest ID: %s" % id)
		return

	var q: Dictionary = quests[id]

	if q["status"] != "completed":
		q["status"] = "completed"
		quests[id] = q

		emit_signal("quest_completed", id)

		if autosave:
			save_quests()


# ==========================================================
# 조회 함수들
# ==========================================================
func is_started(id: String) -> bool:
	return quests.has(id) and quests[id]["status"] in ["in_progress", "completed"]


func is_completed(id: String) -> bool:
	return quests.has(id) and quests[id]["status"] == "completed"


# ==========================================================
# 모든 퀘스트 완료 체크 (DAY 조건)
# ==========================================================
func all_quests_completed() -> bool:
	for id in quests.keys():
		if quests[id]["status"] != "completed":
			return false
	return true


# ==========================================================
# 전체 조회
# ==========================================================
func get_quest(id: String) -> Dictionary:
	if not quests.has(id):
		return {}
	return quests[id]


func get_all_quests() -> Dictionary:
	return quests.duplicate(true)


# ==========================================================
# 저장하기
# ==========================================================
func save_quests(path: String = "") -> void:
	var p: String = path if path != "" else save_path

	var file := FileAccess.open(p, FileAccess.WRITE)
	if file == null:
		push_error("QuestManager.save_quests: cannot open file %s" % p)
		return

	var data := { "quests": quests }
	var json := JSON.stringify(data)

	file.store_string(json)
	file.close()


# ==========================================================
# 로드하기
# ==========================================================
func load_quests(path: String = "") -> void:
	var p: String = path if path != "" else save_path

	if not FileAccess.file_exists(p):
		print("QuestManager: 저장 파일 없음 → 새 시작")
		return

	var file := FileAccess.open(p, FileAccess.READ)
	if file == null:
		push_error("QuestManager.load_quests: cannot open %s" % p)
		return

	var text: String = file.get_as_text()
	file.close()

	var parsed: Dictionary = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("QuestManager.load_quests: JSON 파싱 오류")
		return

	if parsed.has("quests"):
		quests = parsed["quests"]
	else:
		quests = {}

	print("QuestManager: 로드 완료 →", quests.keys())
	emit_signal("quests_loaded")
