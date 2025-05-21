package main

import "core:math"
import glm "core:math/linalg/glsl"

Camera :: struct {
	position:    glm.vec3,
	front:       glm.vec3,
	up:          glm.vec3,
	world_up:    glm.vec3,
	right:       glm.vec3,
	yaw:         f32,
	pitch:       f32,
	sensitivity: f32,
	zoom:        f32,
}

Direction :: enum {
	Forward,
	Backward,
	Left,
	Right,
}

get_view_matrix :: proc(camera: ^Camera) -> glm.mat4 {
	return glm.mat4LookAt(camera.position, camera.front + camera.position, camera.up)
}

move_camera :: proc(camera: ^Camera, direction: Direction, timedelta: f32) {
	velocity := 2.5 * timedelta
	switch direction {
	case .Forward:
		camera.position += camera.front * velocity
	case .Backward:
		camera.position -= camera.front * velocity
	case .Left:
		camera.position -= camera.right * velocity
	case .Right:
		camera.position += camera.right * velocity
	}
}

update_camera_positions :: proc(camera: ^Camera) {
	direction: glm.vec3
	direction.x = math.cos(math.to_radians(camera.yaw)) * math.cos(math.to_radians(camera.pitch))
	direction.y = math.sin(math.to_radians(camera.pitch))
	direction.z = math.sin(math.to_radians(camera.yaw)) * math.cos(math.to_radians(camera.pitch))
	camera.front = glm.normalize(direction)

	camera.right = glm.normalize(glm.cross_vec3(camera.front, camera.world_up))
	camera.up = glm.normalize(glm.cross_vec3(camera.right, camera.front))
}

new_camera :: proc(
	position := glm.vec3{0, 0, 0},
	up := glm.vec3{0, 1, 0},
	yaw: f32 = -90,
	pitch: f32 = 0,
) -> Camera {
	camera := Camera {
		position = position,
		up       = up,
		yaw      = yaw,
		pitch    = pitch,
	}
	camera.front = glm.vec3{0, 0, -1}
	camera.world_up = up
	camera.sensitivity = 0.1
	camera.zoom = 45.0
	update_camera_positions(&camera)
	return camera
}

process_mouse_movement :: proc(
	camera: ^Camera,
	x_offset, y_offset: f32,
	constraint_pitch := true,
) {
	sensitivity: f32 : 0.1
	camera.yaw += (x_offset * camera.sensitivity)
	camera.pitch += (y_offset * camera.sensitivity)
	if constraint_pitch {
		if (camera.pitch > 89.0) {
			camera.pitch = 89.0
		}
		if (camera.pitch < -89.0) {
			camera.pitch = -89.0
		}
	}
	update_camera_positions(camera)
}


process_mouse_scroll :: proc(camera: ^Camera, y_offset: f32) {
	camera.zoom -= y_offset
	if (camera.zoom < 1){
		camera.zoom = 1
	}
	if (camera.zoom > 45){
		camera.zoom = 45
	}
}
