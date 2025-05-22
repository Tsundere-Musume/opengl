#version 330 core

layout(location = 0) in vec3 a_pos;
layout(location = 1) in vec3 a_normal;

// out vec2 tex_coord;
out vec3 FragPos;
out vec3 Normal;

uniform mat4 proj;
uniform mat4 view;
uniform mat4 model;

void main() {
    gl_Position = proj * view * model * vec4(a_pos, 1.0);
	FragPos = vec3(model * vec4(a_pos, 1));
	Normal = mat3(transpose(inverse(model))) * a_normal;
}
