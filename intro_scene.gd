extends Control

# 보여줄 문장들
@export var lines: Array[String] = [
	"당신은 살인사건의 탐정입니다.",
	"당신은 저택 사건을 해결하러 이 저택에 오게 되었습니다.",
	"이 저택에서 알맞은 범인을 찾아야 이 게임을 클리어 할 수 있습니다.",
	"SPACE 버튼을 눌러 조사를 시작하세요."
]


# 마지막에 넘어갈 씬
@export_file("*.tscn")
var next_scene: String = "res://scenes/Stage1.tscn"

# 타이핑 속도 (초당 글자 수)
@export var typing_speed: float = 20.0

@onready var label: Label = $ColorRect/Label

var current_index: int = 0          # 현재 몇 번째 줄인지
var current_text: String = ""       # 현재 타이핑 중인 문장
var current_char_index: int = 0     # 지금까지 보여준 글자 수
var typing_timer: float = 0.0       # 시간 누적용
var is_typing: bool = false         # 타이핑 중인지 여부

func _ready() -> void:
	# 폰트 바꾸기
	var f: FontFile = load("res://ThinDungGeunMo.ttf")
	label.add_theme_font_override("font", f)
	set_process(true)  # _process(delta) 켜기
	_start_line()      # 첫 번째 줄 시작

func _process(delta: float) -> void:
	if not is_typing:
		return

	typing_timer += delta
	# typing_speed = 초당 몇 글자인지, 그만큼 글자 수 증가
	var chars_to_show := int(typing_timer * typing_speed)

	if chars_to_show > current_char_index:
		current_char_index = min(chars_to_show, current_text.length())
		label.text = current_text.substr(0, current_char_index)

	# 한 줄 다 타이핑 되면 멈춤
	if current_char_index >= current_text.length():
		is_typing = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("next_text"):
		if is_typing:
			# 타이핑 중일 때 Space 누르면 → 바로 전체 문장 보여주기
			is_typing = false
			current_char_index = current_text.length()
			label.text = current_text
		else:
			# 이미 다 나온 상태에서 Space → 다음 문장으로
			_next_line()

func _start_line() -> void:
	# 모든 문장을 다 봤으면 다음 씬으로
	if current_index >= lines.size():
		DayManager.change_day(1)
		return

	current_text = lines[current_index]
	current_char_index = 0
	typing_timer = 0.0
	label.text = ""
	is_typing = true

func _next_line() -> void:
	current_index += 1
	_start_line()
