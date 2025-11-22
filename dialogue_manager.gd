extends Node

signal dialogue_finished

var ui_panel : Control
var npc_name_label : Label
var npc_text_label : Label
var player_text_label : Label

var dialogue_lines = []
var index = 0
var talking = false

func _ready():
	# 씬이 바뀌면 UI 다시 찾도록 연결
	get_tree().tree_changed.connect(_on_tree_changed)
	call_deferred("_find_ui")  # 첫 씬 로딩 후 UI 찾기

func _on_tree_changed():
	# 씬 변경 후 다시 UI 찾기
	call_deferred("_find_ui")

func _find_ui():
	var root = get_tree().get_current_scene()
	if root == null:
		return

	# DialogueUI가 현재 씬 안에 있는지 확인
	if root.has_node("DialogueUI/Panel"):
		ui_panel = root.get_node("DialogueUI/Panel")
		npc_name_label = ui_panel.get_node("NpcName")
		npc_text_label = ui_panel.get_node("NpcText")
		player_text_label = ui_panel.get_node("PlayerText")

		print("✅ DialogueUI 연결됨:", root.name)
	else:
		print("⚠ DialogueUI가", root.name, "안에 없음")


# ============================================================
# JSON 대사 로딩 (display_name 포함 버전)
# ============================================================
func load_dialogue(npc_file: String, key: String) -> Dictionary:
	var path = "res://dialogues/%s.json" % npc_file

	if !FileAccess.file_exists(path):
		push_error("❌ 대사 파일 없음: " + path)
		return {"name": npc_file, "lines": []}

	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	var data = JSON.parse_string(text)

	if typeof(data) != TYPE_DICTIONARY:
		push_error("❌ JSON 파싱 오류: " + path)
		return {"name": npc_file, "lines": []}

	# JSON에 표시 이름이 있으면 사용, 없으면 파일명 사용
	var display_name = data.get("display_name", npc_file)

	# 대사 key ("first", "second", "quest_start") 읽기
	var lines = data.get(key, [])

	return {
		"name": display_name,
		"lines": lines
	}


# ============================================================
# 대화 시작
# ============================================================
func start_dialogue(npc_name: String, lines: Array):
	if ui_panel == null:
		push_error("❌ UI 패널이 연결되지 않음! 씬 안에 DialogueUI가 있는지 확인.")
		return

	dialogue_lines = lines
	index = 0
	talking = true

	ui_panel.visible = true
	npc_name_label.text = npc_name  # display_name 표시

	_show_line()


func _show_line():
	var line = dialogue_lines[index]

	# NPC 말
	if line.has("npc"):
		npc_text_label.visible = true
		npc_text_label.text = line["npc"]
	else:
		npc_text_label.visible = false

	# Player 말
	if line.has("player"):
		player_text_label.visible = true
		player_text_label.text = line["player"]
	else:
		player_text_label.visible = false


func next():
	if !talking:
		return

	index += 1

	if index >= dialogue_lines.size():
		end_dialogue()
		return

	_show_line()


func end_dialogue():
	ui_panel.visible = false
	talking = false
	print("[DialogueManager] 대화 종료 signal emit!")
	emit_signal("dialogue_finished")
