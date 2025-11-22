extends Node

signal quest_added(id: String)
signal quest_started(id: String)
signal quest_completed(id: String)
signal quests_loaded()

func load_day_quests(resource_path: String):
	var res = load(resource_path)
	if res == null:
		push_error("❌ day quests 파일 로드 실패: " + resource_path)
		return
	
	if not res.has_method("get"):
		push_error("❌ day quests 파일에 quests 변수가 없음")
		return

	var quest_array = res.quests

	for q in quest_array:
		var id = q["id"]
		var name = q["name"]
		var desc = q["desc"]

		add_quest(id, name, desc)

	print("📌 Day quests 로드 완료:", quest_array.size())

var quests: Dictionary = {}

var autosave: bool = true
var save_path: String = "user://quests.save"


func _ready() -> void:
	if FileAccess.file_exists(save_path):
		load_quests()


# ----------------------
# 퀘스트 추가
# ----------------------
func add_quest(id: String, name: String, desc: String = "") -> void:
	if quests.has(id):
		return

	quests[id] = {
		"name": name,
		"desc": desc,
		"status": "not_started"
	}

	emit_signal("quest_added", id)

	if autosave:
		save_quests()


# ----------------------
# 퀘스트 시작
# ----------------------
func start_quest(id: String) -> void:
	if not quests.has(id):
		return

	var q: Dictionary = quests[id]

	if q["status"] == "not_started":
		q["status"] = "in_progress"
		quests[id] = q
		emit_signal("quest_started", id)

		if autosave:
			save_quests()


# ----------------------
# 퀘스트 완료
# ----------------------
func complete_quest(id: String) -> void:
	if not quests.has(id):
		return

	var q: Dictionary = quests[id]

	if q["status"] != "completed":
		q["status"] = "completed"
		quests[id] = q
		emit_signal("quest_completed", id)

		if autosave:
			save_quests()


# ----------------------
# 조회 함수들
# ----------------------
func is_completed(id: String) -> bool:
	return quests.has(id) and quests[id]["status"] == "completed"


func get_all_quests() -> Dictionary:
	return quests.duplicate(true)


# ----------------------
# 저장
# ----------------------
func save_quests(path: String = "") -> void:
	var p: String = path if path != "" else save_path

	var file := FileAccess.open(p, FileAccess.WRITE)
	if file == null:
		return

	var data := {"quests": quests}
	file.store_string(JSON.stringify(data))
	file.close()


# ----------------------
# 로드
# ----------------------
func load_quests(path: String = "") -> void:
	var p: String = path if path != "" else save_path

	if not FileAccess.file_exists(p):
		return

	var file := FileAccess.open(p, FileAccess.READ)
	if file == null:
		return

	var text: String = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)

	if typeof(parsed) != TYPE_DICTIONARY:
		return

	if parsed.has("quests"):
		quests = parsed["quests"]
	else:
		quests = {}

	emit_signal("quests_loaded")
