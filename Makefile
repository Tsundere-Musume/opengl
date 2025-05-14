# Use the C++ compiler for C++ files and C compiler for C files
CXX = g++
CC = gcc

CXXFLAGS = -Wall -std=c++17
CFLAGS = -Wall

LIBS =  -lglfw3 -lGL -lX11 -lpthread -lXrandr -lXi -ldl

# Output binary directory
BIN_DIR = bin
# Object files directory
OBJ_DIR = obj

# Output binary
TARGET = $(BIN_DIR)/app

# Source files
SRC = main.cpp glad.c Shader.cpp image.cpp

# Object files (stored in obj/ directory)
OBJ = $(patsubst %.cpp, $(OBJ_DIR)/%.o, $(filter %.cpp, $(SRC))) \
      $(patsubst %.c, $(OBJ_DIR)/%.o, $(filter %.c, $(SRC)))

# Ensure that object directories exist before compilation
$(OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Default target
all: $(TARGET)

$(TARGET): $(OBJ)
	@mkdir -p $(BIN_DIR)
	$(CXX) $(OBJ) -o $(TARGET) $(LIBS)

clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)

run: $(TARGET)
	./$(TARGET)

