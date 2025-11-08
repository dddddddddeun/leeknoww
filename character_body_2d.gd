extends CharacterBody2D

@export var speed: float = 200.0
@onready var sprite: Sprite2D = $Sprite

# 각 방향별 3프레임 (idle, walk1, walk2)
@export var sprite_up_frames: Array[Texture] = []
@export var sprite_down_frames: Array[Texture] = []
@export var sprite_left_frames: Array[Texture] = []
@export var sprite_right_frames: Array[Texture] = []
@export var sprite_up_left_frames: Array[Texture] = []
@export var sprite_up_right_frames: Array[Texture] = []
@export var sprite_down_left_frames: Array[Texture] = []
@export var sprite_down_right_frames: Array[Texture] = []

@export var frame_time: float = 0.5  # 걷는 프레임 전환 속도
var _frame_timer: float = 0.0
var _frame_index: int = 1  # 1과 2 사이에서 반복 (0은 idle)
var _current_frames: Array[Texture] = []
var _last_direction: Vector2 = Vector2.DOWN

func _ready():
	add_to_group("Player")

func _physics_process(delta):
	var direction := Vector2.ZERO

	# --- 방향키 입력 ---
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		_last_direction = direction
		_current_frames = _get_frames_for_direction(direction)

		# 프레임2 ↔ 프레임3 반복
		if _current_frames.size() >= 3:
			_frame_timer += delta
			if _frame_timer >= frame_time:
				_frame_timer = 0.0
				# frame2(인덱스1) ↔ frame3(인덱스2) 토글
				_frame_index = 2 if _frame_index == 1 else 1
			sprite.texture = _current_frames[_frame_index]
		else:
			# 혹시 배열이 비었을 경우 예외처리
			sprite.texture = _current_frames[0]
	else:
		# 키를 떼면 frame1 (정지 상태) 표시
		var frames = _get_frames_for_direction(_last_direction)
		if frames.size() > 0:
			sprite.texture = frames[0]
		_frame_index = 1
		_frame_timer = 0.0

	# 이동
	velocity = direction * speed


# === 방향별 프레임 배열 반환 ===
func _get_frames_for_direction(direction: Vector2) -> Array[Texture]:
	if direction.x > 0.5 and direction.y < -0.5:
		return sprite_up_right_frames
	elif direction.x < -0.5 and direction.y < -0.5:
		return sprite_up_left_frames
	elif direction.x > 0.5 and direction.y > 0.5:
		return sprite_down_right_frames
	elif direction.x < -0.5 and direction.y > 0.5:
		return sprite_down_left_frames
	elif direction.y < -0.5:
		return sprite_up_frames
	elif direction.y > 0.5:
		return sprite_down_frames
	elif direction.x < -0.5:
		return sprite_left_frames
	elif direction.x > 0.5:
		return sprite_right_frames
	return []
