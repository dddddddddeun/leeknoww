extends Node

var current_day := 1
var max_day := 3

var day_main_scene := {
	1: "res://day1/day1_scene_1.tscn",
	#2: "res://days/day2_scene_1.tscn",
	#3: "res://days/day3_scene_1.tscn"
}

func _ready() -> void:
	# ❗ 자동 로드 금지
	# _load_day_scene(current_day)
	pass

# ======================================================
# Day 변경
# ======================================================
func change_day(new_day: int) -> void:
	if new_day < 1 or new_day > max_day:
		push_error("DayManager: 잘못된 day: %s" % new_day)
		return

	current_day = new_day

	# 새 day의 메인씬 로드
	_load_day_scene(current_day)

	# 모든 퀘스트 초기화 후 다시 등록
	_reset_day_quests()

	emit_signal("day_changed", current_day)
	print("Day changed →", current_day)


# ======================================================
# 다음 Day로 넘어가기
# ======================================================
func next_day() -> void:
	if current_day >= max_day:
		print("마지막 Day입니다.")
		return

	current_day += 1

	# 씬 로드
	_load_day_scene(current_day)

	# 퀘스트 초기화 + 재등록
	_reset_day_quests()

	emit_signal("day_changed", current_day)
	print("Next Day →", current_day)


# ======================================================
# Day의 메인 씬 불러오기
# ======================================================
func _load_day_scene(day: int) -> void:
	if not day_main_scene.has(day):
		push_error("DayManager: day_main_scene에 %s가 없음" % day)
		return

	var path = day_main_scene[day]
	var scene = load(path)

	if scene == null:
		push_error("DayManager: 씬 로드 실패: %s" % path)
		return

	get_tree().change_scene_to_packed(scene)


# ======================================================
# Day별 퀘스트 초기화 + 재등록
# ======================================================
func _reset_day_quests():
	# 모든 기존 퀘스트 제거
	QuestManager.quests.clear()

	# Day별 신규 퀘스트 등록
	match current_day:
		1:
			_register_day1_quests()

		2:
			_register_day2_quests()

		3:
			_register_day3_quests()

	print("Day", current_day, "퀘스트 초기화 완료")


# ======================================================
# Day 1 퀘스트 등록
# ======================================================
func _register_day1_quests():
	QuestManager.add_quest(
		"police_talk_1",
		"경찰과 첫 대화하기",
		"마을 경찰에게 최초로 말을 걸어보자"
	)

	QuestManager.add_quest(
		"police_talk_2",
		"경찰과 두 번째 대화하기",
		"경찰에게 다시 말을 건다."
	)


# ======================================================
# Day 2 퀘스트 등록
# ======================================================
func _register_day2_quests():
	QuestManager.add_quest(
		"shopkeeper_talk_1",
		"상점 주인에게 말걸기",
		"상점 주인에게 첫 말을 걸기"
	)


# ======================================================
# Day 3 퀘스트 등록
# ======================================================
func _register_day3_quests():
	QuestManager.add_quest(
		"mayor_talk_1",
		"마을장과 대화하기",
		"마을 장로에게 중요한 정보를 듣기"
	)


# ======================================================
# 모든 퀘스트 완료되면 next day 버튼 허용
# ======================================================
func check_next_day_condition():
	if QuestManager.all_quests_completed():
		emit_signal("next_day_unlocked")
