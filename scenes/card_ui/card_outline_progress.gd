class_name OutlineProgressPanel
extends Panel

# 进度（0.0 到 1.0）
var progress: float = 0.0 :set = set_progress

# 轮廓宽度
const outline_width = 2


#func _ready() -> void:
	#call_deferred("init_setup")


func init_setup():
	size = get_parent().size + Vector2(outline_width * 2, outline_width * 2)
	position = -Vector2(outline_width, outline_width)
	material = material.duplicate()

# 设置进度并更新绘制
func set_progress(value: float) -> void:
	progress = clamp(value, 0.0, 1.0)
	if material is ShaderMaterial:
		material.set_shader_parameter("node_size", size)
		material.set_shader_parameter("progress", progress)
	
	
