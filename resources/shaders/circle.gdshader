shader_type canvas_item;

// Радиус скругления в пикселях
uniform float radius = 32.0;
// Размер контейнера (передается автоматически или задается вручную)
uniform vec2 size = vec2(256.0, 256.0);

// Функция для вычисления расстояния до углов (SDF)
float rounded_box(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
    // Центрируем координаты UV и переводим в пиксели
    vec2 center = size * 0.5;
    vec2 p = (UV * size) - center;
    
    // Половина размера за вычетом радиуса для SDF
    vec2 half_size = size * 0.5;
    
    // Вычисляем дистанцию до границ
    float dist = rounded_box(p, half_size, radius);
    
    // Создаем маску сглаживания (antialiasing)
    float mask = smoothstep(1.0, 0.0, dist);
    
    // Применяем маску к прозрачности
    vec4 color = texture(TEXTURE, UV);
    COLOR = vec4(color.rgb, color.a * mask);
}
