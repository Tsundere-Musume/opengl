// clang-format off
#include <cstddef>
#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <iostream>
// clang-format on

const char *vertexShaderSource =
    "#version 330 core\n"
    "layout (location = 0) in vec3 aPos;\n"
    "void main()\n"
    "{\n"
    " gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
    "}\0";

const char *fragmentShaderSource =
    "#version 330 core\n"
    "out vec4 FragColor;\n"
    "void main()\n"
    "{\n"
    "	FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n"
    "}\0";

const char *yellowFragmentShaderSource =
    "#version 330 core\n"
    "out vec4 FragColor;\n"
    "void main()\n"
    "{\n"
    "	FragColor = vec4(0.99, 1.00, 0.00, 1.0);\n"
    "}\0";
void framebuffer_size_callback(GLFWwindow *window, int width, int height);
void processInput(GLFWwindow *window);

int main(int argc, char *argv[]) {
  glfwInit();
  glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
  glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
  glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

  GLFWwindow *window = glfwCreateWindow(800, 600, "LearnOpenGL", NULL, NULL);
  if (window == NULL) {
    std::cout << "Failed to create GLFW window" << std::endl;
    glfwTerminate();
    return -1;
  }

  glfwMakeContextCurrent(window);
  glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

  if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
    std::cout << "Failed to initialize GLAD" << std::endl;
    return -1;
  }

  // triangle
  int success;
  char infoLog[512];
  // Vertex Shader
  unsigned int vertexShader;
  vertexShader = glCreateShader(GL_VERTEX_SHADER);
  glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
  glCompileShader(vertexShader);

  glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);

  if (!success) {
    glGetShaderInfoLog(vertexShader, 512, NULL, infoLog);
    std::cout << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n"
              << infoLog << std::endl;
  }

  // Fragmnet Shader
  unsigned int fragmentShader;
  fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
  glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
  glCompileShader(fragmentShader);

  glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);

  if (!success) {
    glGetShaderInfoLog(fragmentShader, 512, NULL, infoLog);
    std::cout << "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n"
              << infoLog << std::endl;
  }


  // yellow fragment shader
  unsigned int yellowFragmentShader;
  yellowFragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
  glShaderSource(yellowFragmentShader, 1, &yellowFragmentShaderSource, NULL);
  glCompileShader(yellowFragmentShader);

  glGetShaderiv(yellowFragmentShader, GL_COMPILE_STATUS, &success);

  if (!success) {
    glGetShaderInfoLog(yellowFragmentShader, 512, NULL, infoLog);
    std::cout << "ERROR::SHADER::YELLOW_FRAGMENT::COMPILATION_FAILED\n"
              << infoLog << std::endl;
  }

  // shader program
  unsigned int shaderProgram;
  shaderProgram = glCreateProgram();
  glAttachShader(shaderProgram, vertexShader);
  glAttachShader(shaderProgram, fragmentShader);
  glLinkProgram(shaderProgram);
  glGetShaderiv(shaderProgram, GL_LINK_STATUS, &success);
  if (!success) {
    glGetShaderInfoLog(shaderProgram, 512, NULL, infoLog);
    std::cout << "ERROR::SHADER::PROGRAM::COMPILATION_FAILED\n"
              << infoLog << std::endl;
  }


  // yello shader program
  unsigned int yellowShaderProgram;
  yellowShaderProgram = glCreateProgram();
  glAttachShader(yellowShaderProgram, vertexShader);
  glAttachShader(yellowShaderProgram, yellowFragmentShader);
  glLinkProgram(yellowShaderProgram);
  glGetShaderiv(yellowShaderProgram, GL_LINK_STATUS, &success);
  if (!success) {
    glGetShaderInfoLog(yellowShaderProgram, 512, NULL, infoLog);
    std::cout << "ERROR::YELLOW_SHADER::PROGRAM::COMPILATION_FAILED\n"
              << infoLog << std::endl;
  }

  // delete the shader objects after linking to the shader program
  glDeleteShader(vertexShader);
  glDeleteShader(fragmentShader);

  // clang-format off
  float vertices[] = {
      -1.0f, -0.5f, 0,
	  	0,   -0.5f, 0,
	  -0.5f,  0.5f, 0,
      	0, -0.5f, 0,
	  	1,   -0.5f, 0,
	0.5f,  0.5f, 0,
  };
  // clang-format on

  // Vertex Buffer Object
  unsigned int VBO ;
  unsigned int VAO;
  glGenBuffers(1, &VBO);
  glGenVertexArrays(1, &VAO);

  glBindVertexArray(VAO);

  glBindBuffer(GL_ARRAY_BUFFER, VBO);
  glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices,
               GL_STATIC_DRAW);
  glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
  glEnableVertexAttribArray(0);

  glBindVertexArray(0);

  // Wireframe mode
  // glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
  // render loop
  while (!glfwWindowShouldClose(window)) {
    // input
    processInput(window);

    // rendering commands
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f); // state setting function
    glClear(GL_COLOR_BUFFER_BIT);         // state using function

    // triangles wooooo
    glUseProgram(shaderProgram);
    glBindVertexArray(VAO);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glUseProgram(yellowShaderProgram);
    glDrawArrays(GL_TRIANGLES, 3, 3);

    // check and call events and swap the buffers
    glfwSwapBuffers(window);
    glfwPollEvents();
  }

  glDeleteVertexArrays(1, &VAO);
  glDeleteBuffers(1, &VBO);
  glDeleteProgram(shaderProgram);
  glfwTerminate();
  return 0;
}

void framebuffer_size_callback(GLFWwindow *window, int width, int height) {
  glViewport(0, 0, width, height);
}

void processInput(GLFWwindow *window) {
  if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
    glfwSetWindowShouldClose(window, true);
  }
}
