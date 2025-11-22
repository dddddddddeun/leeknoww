extends CharacterBody2D

var npc_file := "npc_police"
	# JSON 파일 이름 (res://dialogues/npc_police.json)
var talk_count := 0              # 몇 번째 대화를 하는지 저장
var player_in_range := false     # 플레이어가 NPC 옆에 있는지 감지

func _ready():
	# DialogueManager가 대화 끝났다고 하면 quest 완료 신호 받기
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)

func _process(delta):
	# 플레이어가 범위 안에 있고 R을 눌렀고, 현재 대화 중이 아닐 때
	if player_in_range and Input.is_action_just_pressed("interact_r"):
		_start_talk()

# ---------------------------------------
#  플레이어와 상호작용 트리거 (Collision or Area2D)
# ---------------------------------------
func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false


# ---------------------------------------
#  대화 시작
# ---------------------------------------
func _start_talk():
	talk_count += 1

	var key := ""
	if talk_count == 1:
		key = "first"
	elif talk_count == 2:
		key = "second"
	else:
		key = "repeat"   # JSON에서 repeat 항목 넣어두면 다음부터 반복 가능

	# JSON 파일에서 대사 불러오기
	var result = DialogueManager.load_dialogue(npc_file, key)

	# result["name"] 은 JSON의 display_name
	# result["lines"] 는 해당 대사 목록
	DialogueManager.start_dialogue(result["name"], result["lines"])


# ---------------------------------------
#  대화가 끝났을 때 실행되는 함수 (퀘스트 완료 신호 처리)
# ---------------------------------------
func _on_dialogue_finished():
	if talk_count == 1:
		QuestManager.complete_quest("police_talk_1")
	elif talk_count == 2:
		QuestManager.complete_quest("police_talk_2")
	print("[POLICE] dialogue finished received! talk_count =", talk_count)


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
