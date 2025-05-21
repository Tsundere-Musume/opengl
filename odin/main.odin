package main

import "core:c"
import "core:fmt"
import "core:time"

import "base:runtime"
import glm "core:math/linalg/glsl"

import gl "vendor:OpenGL"
import "vendor:glfw"
import "vendor:stb/image"


GL_VERSION_MAJOR :: 3
GL_VERSION_MINOR :: 3

WINDOW_WIDTH :: 800.0
WINDOW_HEIGHT :: 600.0

timedelta, lastframe: f32
last_x := 400.0
last_y := 300.0
camera := new_camera({0, 0, 3})
first_mouse := true

light_pos: glm.vec3 = {1.2, 1.0, 2.0}

main :: proc() {
	if !glfw.Init() {
		fmt.eprintln("Failed to initialize GLFW")
		return
	}
	defer glfw.Init()

	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_VERSION_MAJOR)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_VERSION_MINOR)

	window := glfw.CreateWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "LearnOpenGL", nil, nil)
	defer glfw.DestroyWindow(window)

	if window == nil {
		fmt.eprintln("failed to create a GLFW window")
		return
	}

	glfw.MakeContextCurrent(window)
	gl.load_up_to(GL_VERSION_MAJOR, GL_VERSION_MINOR, glfw.gl_set_proc_address)
	gl.Enable(gl.DEPTH_TEST)

	//callbacks
	// glfw.SetKeyCallback(window, key_callback)
	glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)
	glfw.SetFramebufferSizeCallback(window, framebuffer_size_callback)
	glfw.SetCursorPosCallback(window, mouse_callback)
	glfw.SetScrollCallback(window, scroll_callback)

	Vertex :: struct {
		pos: glm.vec3,
		tex: glm.vec2,
	}
	vertices := []Vertex {
		{{-0.5, -0.5, -0.5}, {0.0, 0.0}},
		{{0.5, -0.5, -0.5}, {1.0, 0.0}},
		{{0.5, 0.5, -0.5}, {1.0, 1.0}},
		{{0.5, 0.5, -0.5}, {1.0, 1.0}},
		{{-0.5, 0.5, -0.5}, {0.0, 1.0}},
		{{-0.5, -0.5, -0.5}, {0.0, 0.0}},
		{{-0.5, -0.5, 0.5}, {0.0, 0.0}},
		{{0.5, -0.5, 0.5}, {1.0, 0.0}},
		{{0.5, 0.5, 0.5}, {1.0, 1.0}},
		{{0.5, 0.5, 0.5}, {1.0, 1.0}},
		{{-0.5, 0.5, 0.5}, {0.0, 1.0}},
		{{-0.5, -0.5, 0.5}, {0.0, 0.0}},
		{{-0.5, 0.5, 0.5}, {1.0, 0.0}},
		{{-0.5, 0.5, -0.5}, {1.0, 1.0}},
		{{-0.5, -0.5, -0.5}, {0.0, 1.0}},
		{{-0.5, -0.5, -0.5}, {0.0, 1.0}},
		{{-0.5, -0.5, 0.5}, {0.0, 0.0}},
		{{-0.5, 0.5, 0.5}, {1.0, 0.0}},
		{{0.5, 0.5, 0.5}, {1.0, 0.0}},
		{{0.5, 0.5, -0.5}, {1.0, 1.0}},
		{{0.5, -0.5, -0.5}, {0.0, 1.0}},
		{{0.5, -0.5, -0.5}, {0.0, 1.0}},
		{{0.5, -0.5, 0.5}, {0.0, 0.0}},
		{{0.5, 0.5, 0.5}, {1.0, 0.0}},
		{{-0.5, -0.5, -0.5}, {0.0, 1.0}},
		{{0.5, -0.5, -0.5}, {1.0, 1.0}},
		{{0.5, -0.5, 0.5}, {1.0, 0.0}},
		{{0.5, -0.5, 0.5}, {1.0, 0.0}},
		{{-0.5, -0.5, 0.5}, {0.0, 0.0}},
		{{-0.5, -0.5, -0.5}, {0.0, 1.0}},
		{{-0.5, 0.5, -0.5}, {0.0, 1.0}},
		{{0.5, 0.5, -0.5}, {1.0, 1.0}},
		{{0.5, 0.5, 0.5}, {1.0, 0.0}},
		{{0.5, 0.5, 0.5}, {1.0, 0.0}},
		{{-0.5, 0.5, 0.5}, {0.0, 0.0}},
		{{-0.5, 0.5, -0.5}, {0.0, 1.0}},
	}

	// opengl buffers
	vao: u32
	gl.GenVertexArrays(1, &vao);defer gl.DeleteVertexArrays(1, &vao)

	vbo, ebo: u32
	gl.GenBuffers(1, &vbo);defer gl.DeleteBuffers(1, &vbo)
	gl.GenBuffers(1, &ebo);defer gl.DeleteBuffers(1, &ebo)

	gl.BindVertexArray(vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(vertices) * size_of(vertices[0]),
		raw_data(vertices),
		gl.STATIC_DRAW,
	)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, pos))
	gl.EnableVertexAttribArray(0)


	light_vao: u32
	gl.GenVertexArrays(1, &light_vao)
	gl.BindVertexArray(light_vao)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, false, size_of(Vertex), offset_of(Vertex, pos))
	gl.EnableVertexAttribArray(0)

	gl.BindVertexArray(0)
	// shaders
	color_shader_program, light_cube_shader_program: u32
	program_ok: bool
	color_shader_program, program_ok = gl.load_shaders_file(
		"./shaders/color_vs.glsl",
		"./shaders/color_fs.glsl",
	)
	if !program_ok {
		fmt.eprintln("failed to create a shader program: color shader")
		return
	}
	defer gl.DeleteProgram(color_shader_program)
	color_uniforms := gl.get_uniforms_from_program(color_shader_program)

	light_cube_shader_program, program_ok = gl.load_shaders_file(
		"./shaders/light_cube_vs.glsl",
		"./shaders/light_cube_fs.glsl",
	)
	if !program_ok {
		fmt.eprintln("failed to create a shader program: light cube shader")
		return
	}
	defer gl.DeleteProgram(light_cube_shader_program)
	light_cube_uniforms := gl.get_uniforms_from_program(light_cube_shader_program)

	for !glfw.WindowShouldClose(window) {
		current_frame := f32(glfw.GetTime())
		timedelta = f32(current_frame - lastframe)
		lastframe = current_frame

		process_input(window)

		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)


		gl.UseProgram(color_shader_program)
		gl.Uniform3f(color_uniforms["object_color"].location, 1, 0.5, 0.31)
		gl.Uniform3f(color_uniforms["light_color"].location, 1, 1, 1)

		view := get_view_matrix(&camera)
		proj := glm.mat4Perspective(glm.radians_f32(camera.zoom), 800.0 / 600.0, 0.1, 100.0)
		model := glm.mat4(1)
		model = model * glm.mat4Rotate({0.5, 1, 0}, f32(glfw.GetTime()))
		u_transform := proj * view * model
		gl.UniformMatrix4fv(color_uniforms["u_transform"].location, 1, false, &u_transform[0, 0])

		gl.BindVertexArray(vao)
		gl.DrawArrays(gl.TRIANGLES, 0, 36)

		gl.UseProgram(light_cube_shader_program)
		model = glm.mat4(1)
		model = model * glm.mat4Translate(light_pos)
		model = model * glm.mat4Scale(glm.vec3(0.2))
		u_transform = proj * view * model
		gl.UniformMatrix4fv(light_cube_uniforms["u_transform"].location, 1, false, &u_transform[0, 0])
		gl.BindVertexArray(light_vao)
		gl.DrawArrays(gl.TRIANGLES, 0, 36)

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}
}

process_input :: proc(window: glfw.WindowHandle) {
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}
	if glfw.GetKey(window, glfw.KEY_W) == glfw.PRESS {
		move_camera(&camera, Direction.Forward, timedelta)
	}
	if glfw.GetKey(window, glfw.KEY_S) == glfw.PRESS {
		move_camera(&camera, Direction.Backward, timedelta)
	}
	if glfw.GetKey(window, glfw.KEY_A) == glfw.PRESS {
		move_camera(&camera, Direction.Left, timedelta)
	}
	if glfw.GetKey(window, glfw.KEY_D) == glfw.PRESS {
		move_camera(&camera, Direction.Right, timedelta)
	}
}

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	gl.Viewport(0, 0, width, height)
}

mouse_callback :: proc "c" (window: glfw.WindowHandle, xpos, ypos: f64) {
	if first_mouse {
		last_x = xpos
		last_y = ypos
		first_mouse = false
	}
	context = runtime.default_context()
	x_offset := f32(xpos - last_x)
	y_offset := f32(-(ypos - last_y))

	last_x = xpos
	last_y = ypos

	process_mouse_movement(&camera, x_offset, y_offset)
}

scroll_callback :: proc "c" (window: glfw.WindowHandle, x_offset, y_offset: f64) {
	context = runtime.default_context()
	process_mouse_scroll(&camera, f32(y_offset))
}
