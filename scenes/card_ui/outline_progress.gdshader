shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0); // 进度（0.0 到 1.0）
uniform float outline_width: hint_range(0.0, 10.0); // 轮廓宽度
uniform vec2 node_size; // 节点大小（以像素为单位）


float border(vec2 uv, float border_width_px, vec2 texture_size)
{
	vec2 border_width = vec2(border_width_px) / texture_size;
	vec2 bottom_left = step(vec2(border_width), uv);
	vec2 top_right = step(vec2(border_width), 1.0 - uv);
	return bottom_left.x * bottom_left.y * top_right.x * top_right.y;
}


void fragment() {
	float is_border = border(UV, outline_width, node_size);

	if (is_border != 0.0) {
		COLOR = vec4(0.0);
	} else {
	    vec2 delta = UV - vec2(0.5, 0.5);
		float angle = atan(delta.y, delta.x);

		// 将起始点从 3 点钟方向（0 弧度）移动到 12 点钟方向（π/2 弧度）
		angle = angle - 1.570795;
		// 将角度范围从 [-3π/2, π/2] 转换为 [-π, π]
		if (angle < -3.14159) {
			angle = angle + 6.283185;
		}
		angle = angle + 3.14159;
		// 计算当前像素的进度值（0 到 1.0）,用2.05π而不是2π是为了处理π精度低产生低误差
		float pixel_progress = angle / (2.05 * 3.14159);
		// 如果当前像素的进度小于全局进度，则显示
		if (pixel_progress <= progress) {
			COLOR = texture(TEXTURE, UV);
		} else {
			COLOR = vec4(0.0); // 否则透明
		}
	}
}