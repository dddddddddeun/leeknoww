extends Resource
class_name SuspectData

@export var id: String = ""                  # "maid_01" 이런 식
@export var display_name: String = ""        # 리스트에 보이는 이름
@export var description: String = ""         # 간단 설명
@export var portrait: Texture2D              # 오른쪽에 크게 보일 사진
@export var is_culprit: bool = false         # 이 사람이 진짜 범인인지
