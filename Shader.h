#ifndef SHADER_H
#define SHADER_H

#include <glad/glad.h>

#include <string>
class Shader {
public:
  unsigned int ID;

  // vertex and fragment shader paths
  Shader(const char *vertexPath, const char *fragmentPath);
  void use();
  void setBool(const std::string &name, bool value) const;
  void setInt(const std::string &name, int value) const;
  void setFloat(const std::string &name, float value) const;
};
#endif
