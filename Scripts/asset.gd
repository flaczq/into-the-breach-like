extends Util

class_name Asset


func _ready() -> void:
	name = name + '_' + str(randi())
