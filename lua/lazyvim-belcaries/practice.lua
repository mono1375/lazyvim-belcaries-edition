-- LazyVim Belcaries Edition - Comprehensive Interactive Practice
-- Full LazyVim workflow: movement, editing, visual, search, LSP, git, terminal

local M = {}

-- Practice state
local state = {
  active = false,
  project_type = nil,
  project_path = nil,
  current_task = 1,
  current_module = 1,
  completed_tasks = {},
  total_completed = 0,
  popup_win = nil,
  popup_buf = nil,
  autocommand_group = nil,
  last_cursor_pos = nil,
  last_buffer = nil,
  last_search = nil,
  insert_mode_entered = false,
  visual_mode_entered = false,
}

-- Project templates
local templates = {
  python = {
    name = "Python Calculator",
    files = {
      ["main.py"] = [[
# Simple Calculator App
# Practice navigating and editing this project!

def add(a, b):
    """Add two numbers together."""
    return a + b

def subtract(a, b):
    """Subtract b from a."""
    return a - b

def multiply(a, b):
    """Multiply two numbers."""
    return a * b

def divide(a, b):
    """Divide a by b."""
    if b == 0:
        raise ValueError("Cannot divide by zero!")
    return a / b

def power(base, exponent):
    """Calculate base raised to exponent."""
    result = 1
    for i in range(exponent):
        result = result * base
    return result

def main():
    print("=== Python Calculator ===")
    print("Result of 10 + 5:", add(10, 5))
    print("Result of 10 - 5:", subtract(10, 5))
    print("Result of 10 * 5:", multiply(10, 5))
    print("Result of 10 / 5:", divide(10, 5))
    print("Result of 2 ^ 8:", power(2, 8))

if __name__ == "__main__":
    main()
]],
      ["utils.py"] = [[
# Utility functions for the calculator

def validate_number(value):
    """Check if value is a valid number."""
    try:
        float(value)
        return True
    except (ValueError, TypeError):
        return False

def format_result(result, decimals=2):
    """Format a number result with specified decimals."""
    return round(result, decimals)

def get_user_input(prompt):
    """Get input from user with prompt."""
    return input(prompt)

def display_menu():
    """Display the calculator menu."""
    print("1. Add")
    print("2. Subtract")
    print("3. Multiply")
    print("4. Divide")
    print("5. Power")
    print("0. Exit")
]],
      ["tests/test_calculator.py"] = [[
# Unit tests for the calculator

import sys
sys.path.insert(0, '..')
from main import add, subtract, multiply, divide, power

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
    assert add(0, 0) == 0
    print("test_add: PASSED")

def test_subtract():
    assert subtract(5, 3) == 2
    assert subtract(0, 5) == -5
    print("test_subtract: PASSED")

def test_multiply():
    assert multiply(3, 4) == 12
    assert multiply(0, 100) == 0
    print("test_multiply: PASSED")

def test_divide():
    assert divide(10, 2) == 5
    assert divide(7, 2) == 3.5
    print("test_divide: PASSED")

def test_power():
    assert power(2, 3) == 8
    assert power(5, 0) == 1
    print("test_power: PASSED")

if __name__ == "__main__":
    test_add()
    test_subtract()
    test_multiply()
    test_divide()
    test_power()
    print("\n=== All tests passed! ===")
]],
      ["README.md"] = [[
# Python Calculator

A simple calculator project for practicing LazyVim navigation.

## Features
- Basic arithmetic operations (add, subtract, multiply, divide)
- Power function
- Input validation
- Unit tests

## Usage
```bash
python main.py
```

## Running Tests
```bash
python tests/test_calculator.py
```

## Project Structure
- main.py - Main calculator functions
- utils.py - Helper utilities
- tests/ - Unit tests
]],
    },
    run_command = "python main.py",
    test_command = "python tests/test_calculator.py",
  },

  go = {
    name = "Go HTTP Server",
    files = {
      ["main.go"] = [[
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

// Response represents a JSON response
type Response struct {
	Status  string `json:"status"`
	Message string `json:"message"`
}

// Handler for the home page
func homeHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Welcome to Go HTTP Server!")
}

// Handler for the API endpoint
func apiHandler(w http.ResponseWriter, r *http.Request) {
	response := Response{
		Status:  "ok",
		Message: "Hello from Go!",
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// Handler for health check
func healthHandler(w http.ResponseWriter, r *http.Request) {
	response := Response{
		Status:  "healthy",
		Message: "Server is running",
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// Handler for echo endpoint
func echoHandler(w http.ResponseWriter, r *http.Request) {
	message := r.URL.Query().Get("msg")
	if message == "" {
		message = "No message provided"
	}
	response := Response{
		Status:  "ok",
		Message: message,
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/api", apiHandler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/echo", echoHandler)

	port := ":8080"
	fmt.Printf("Server starting on http://localhost%s\n", port)
	fmt.Println("Endpoints: /, /api, /health, /echo?msg=hello")
	log.Fatal(http.ListenAndServe(port, nil))
}
]],
      ["handlers/handlers.go"] = [[
package handlers

import (
	"encoding/json"
	"net/http"
)

// APIResponse structure for JSON responses
type APIResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// JSONResponse writes a JSON response
func JSONResponse(w http.ResponseWriter, data interface{}, status int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	response := APIResponse{
		Success: status < 400,
		Data:    data,
	}
	json.NewEncoder(w).Encode(response)
}

// ErrorResponse writes an error response
func ErrorResponse(w http.ResponseWriter, message string, status int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	response := APIResponse{
		Success: false,
		Error:   message,
	}
	json.NewEncoder(w).Encode(response)
}

// ValidateMethod checks if the request method is allowed
func ValidateMethod(w http.ResponseWriter, r *http.Request, allowed string) bool {
	if r.Method != allowed {
		ErrorResponse(w, "Method not allowed", http.StatusMethodNotAllowed)
		return false
	}
	return true
}
]],
      ["config/config.go"] = [[
package config

import "os"

// ServerConfig holds server configuration
type ServerConfig struct {
	Port    string
	Host    string
	Timeout int
	Debug   bool
}

// DefaultConfig returns default configuration
func DefaultConfig() *ServerConfig {
	return &ServerConfig{
		Port:    getEnv("PORT", "8080"),
		Host:    getEnv("HOST", "localhost"),
		Timeout: 30,
		Debug:   getEnv("DEBUG", "false") == "true",
	}
}

// GetAddress returns the full server address
func (c *ServerConfig) GetAddress() string {
	return c.Host + ":" + c.Port
}

// getEnv gets environment variable with default
func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}
]],
      ["README.md"] = [[
# Go HTTP Server

A simple HTTP server for practicing LazyVim navigation.

## Features
- REST API endpoints
- JSON responses
- Health check endpoint
- Echo endpoint

## Usage
```bash
go run main.go
```

## Endpoints
- `/` - Home page (text)
- `/api` - API endpoint (JSON)
- `/health` - Health check (JSON)
- `/echo?msg=hello` - Echo message (JSON)

## Project Structure
- main.go - Main server and handlers
- handlers/ - Reusable handler utilities
- config/ - Server configuration
]],
    },
    run_command = "go run main.go",
  },

  javascript = {
    name = "JavaScript Todo App",
    files = {
      ["index.js"] = [[
// Simple Todo Application
// Practice navigating and editing this project!

const todos = [];
let nextId = 1;

function addTodo(text) {
  const todo = {
    id: nextId++,
    text: text,
    completed: false,
    createdAt: new Date().toISOString(),
  };
  todos.push(todo);
  console.log(`Added: "${text}" (ID: ${todo.id})`);
  return todo;
}

function removeTodo(id) {
  const index = todos.findIndex((t) => t.id === id);
  if (index !== -1) {
    const removed = todos.splice(index, 1)[0];
    console.log(`Removed: "${removed.text}"`);
    return removed;
  }
  console.log(`Todo with ID ${id} not found`);
  return null;
}

function toggleTodo(id) {
  const todo = todos.find((t) => t.id === id);
  if (todo) {
    todo.completed = !todo.completed;
    const status = todo.completed ? "completed" : "pending";
    console.log(`Toggled: "${todo.text}" -> ${status}`);
  }
  return todo;
}

function listTodos(filter = "all") {
  console.log("\n=== Todo List ===");
  let filtered = todos;
  if (filter === "completed") {
    filtered = todos.filter((t) => t.completed);
  } else if (filter === "pending") {
    filtered = todos.filter((t) => !t.completed);
  }

  if (filtered.length === 0) {
    console.log("No todos found!");
    return;
  }

  filtered.forEach((todo, i) => {
    const status = todo.completed ? "[x]" : "[ ]";
    console.log(`${i + 1}. ${status} ${todo.text} (ID: ${todo.id})`);
  });
  console.log("");
}

function clearCompleted() {
  const before = todos.length;
  const remaining = todos.filter((t) => !t.completed);
  todos.length = 0;
  todos.push(...remaining);
  console.log(`Cleared ${before - remaining.length} completed todos`);
}

// Demo
console.log("=== Todo App Demo ===\n");
addTodo("Learn LazyVim navigation");
addTodo("Practice keybindings");
addTodo("Master text objects");
addTodo("Use LSP features");
toggleTodo(1);
listTodos();
console.log("Filter: pending only");
listTodos("pending");
]],
      ["utils/helpers.js"] = [[
// Helper utilities for the todo app

function formatDate(dateString) {
  const date = new Date(dateString);
  return date.toLocaleDateString("en-US", {
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function generateId() {
  return Math.random().toString(36).substr(2, 9);
}

function validateTodoText(text) {
  if (!text || typeof text !== "string") {
    return { valid: false, error: "Text is required" };
  }
  if (text.trim().length === 0) {
    return { valid: false, error: "Text cannot be empty" };
  }
  if (text.length > 200) {
    return { valid: false, error: "Text too long (max 200 chars)" };
  }
  return { valid: true };
}

function filterTodos(todos, filter) {
  switch (filter) {
    case "completed":
      return todos.filter((t) => t.completed);
    case "pending":
      return todos.filter((t) => !t.completed);
    case "today":
      const today = new Date().toDateString();
      return todos.filter((t) => new Date(t.createdAt).toDateString() === today);
    default:
      return todos;
  }
}

function sortTodos(todos, by = "created") {
  return [...todos].sort((a, b) => {
    if (by === "created") {
      return new Date(b.createdAt) - new Date(a.createdAt);
    }
    if (by === "text") {
      return a.text.localeCompare(b.text);
    }
    if (by === "status") {
      return a.completed - b.completed;
    }
    return 0;
  });
}

module.exports = {
  formatDate,
  generateId,
  validateTodoText,
  filterTodos,
  sortTodos,
};
]],
      ["tests/todo.test.js"] = [[
// Tests for todo functionality

const assert = require("assert");

// Mock todos array for testing
let testTodos = [];
let testNextId = 1;

function addTestTodo(text) {
  const todo = {
    id: testNextId++,
    text: text,
    completed: false,
    createdAt: new Date().toISOString(),
  };
  testTodos.push(todo);
  return todo;
}

function toggleTestTodo(id) {
  const todo = testTodos.find((t) => t.id === id);
  if (todo) {
    todo.completed = !todo.completed;
  }
  return todo;
}

function runTests() {
  console.log("=== Running Tests ===\n");

  // Test 1: Add todo
  testTodos = [];
  testNextId = 1;
  const todo1 = addTestTodo("Test todo");
  assert(testTodos.length === 1, "Should have 1 todo");
  assert(todo1.text === "Test todo", "Text should match");
  assert(todo1.id === 1, "ID should be 1");
  console.log("Test 1: Add todo - PASSED");

  // Test 2: Todo properties
  assert(todo1.completed === false, "Should be incomplete");
  assert(typeof todo1.createdAt === "string", "Should have createdAt");
  console.log("Test 2: Todo properties - PASSED");

  // Test 3: Multiple todos
  addTestTodo("Second todo");
  addTestTodo("Third todo");
  assert(testTodos.length === 3, "Should have 3 todos");
  assert(testTodos[1].id === 2, "Second todo ID should be 2");
  console.log("Test 3: Multiple todos - PASSED");

  // Test 4: Toggle todo
  toggleTestTodo(1);
  assert(testTodos[0].completed === true, "Should be completed");
  toggleTestTodo(1);
  assert(testTodos[0].completed === false, "Should be incomplete again");
  console.log("Test 4: Toggle todo - PASSED");

  // Test 5: Filter todos
  testTodos[0].completed = true;
  const completed = testTodos.filter((t) => t.completed);
  const pending = testTodos.filter((t) => !t.completed);
  assert(completed.length === 1, "Should have 1 completed");
  assert(pending.length === 2, "Should have 2 pending");
  console.log("Test 5: Filter todos - PASSED");

  console.log("\n=== All Tests Passed! ===");
}

runTests();
]],
      ["README.md"] = [[
# JavaScript Todo App

A simple todo application for practicing LazyVim navigation.

## Features
- Add/remove todos
- Toggle completion status
- List filtering (all, completed, pending)
- Clear completed todos

## Usage
```bash
node index.js
```

## Running Tests
```bash
node tests/todo.test.js
```

## Project Structure
- index.js - Main todo functions
- utils/helpers.js - Helper utilities
- tests/ - Unit tests
]],
    },
    run_command = "node index.js",
    test_command = "node tests/todo.test.js",
  },
}

-- Comprehensive practice modules with all keybindings
local practice_modules = {
  -- MODULE 1: Basic Movement
  {
    name = "Basic Movement",
    description = "Learn to move around efficiently",
    tasks = {
      {
        id = "move_hjkl",
        title = "Basic Movement (hjkl)",
        instruction = "Move around using h (left), j (down), k (up), l (right)",
        hint = "Try: 5j to move 5 lines down, 3l to move 3 chars right",
        detect = function()
          local pos = vim.api.nvim_win_get_cursor(0)
          if state.last_cursor_pos then
            local moved = pos[1] ~= state.last_cursor_pos[1] or pos[2] ~= state.last_cursor_pos[2]
            if moved then
              state.last_cursor_pos = pos
              return true
            end
          end
          state.last_cursor_pos = pos
          return false
        end,
        auto_advance = 3,
      },
      {
        id = "move_words",
        title = "Word Movement (w, b, e)",
        instruction = "Move by words: w (next word), b (back word), e (end of word)",
        hint = "Try: 3w to jump 3 words forward",
        auto_advance = 4,
      },
      {
        id = "move_line",
        title = "Line Navigation (0, $, ^)",
        instruction = "Move within line: 0 (start), $ (end), ^ (first non-blank)",
        hint = "Press 0 then $ to go start to end",
        auto_advance = 4,
      },
      {
        id = "move_file",
        title = "File Navigation (gg, G)",
        instruction = "Move in file: gg (top), G (bottom), 10G (line 10)",
        hint = "Try: gg to go to top, then G to go to bottom",
        detect = function()
          local line = vim.api.nvim_win_get_cursor(0)[1]
          local total = vim.api.nvim_buf_line_count(0)
          return line == 1 or line == total
        end,
      },
      {
        id = "move_screen",
        title = "Screen Movement (Ctrl+d/u/f/b)",
        instruction = "Scroll: Ctrl+d (half down), Ctrl+u (half up), Ctrl+f/b (full page)",
        hint = "Try Ctrl+d then Ctrl+u",
        auto_advance = 4,
      },
      {
        id = "move_find",
        title = "Find on Line (f, t, ;)",
        instruction = "Find char: f{char} (find), t{char} (till), ; (repeat)",
        hint = "Try: fa to find 'a', then ; to find next 'a'",
        auto_advance = 5,
      },
    },
  },

  -- MODULE 2: Editing
  {
    name = "Editing Text",
    description = "Insert, delete, change, and manipulate text",
    tasks = {
      {
        id = "insert_modes",
        title = "Insert Mode (i, I, a, A, o, O)",
        instruction = "Enter insert: i (before), a (after), I (line start), A (line end), o/O (new line)",
        hint = "Try: i to insert, type something, then Esc to exit",
        detect = function()
          local mode = vim.api.nvim_get_mode().mode
          if mode == "i" then
            state.insert_mode_entered = true
          end
          if state.insert_mode_entered and mode == "n" then
            state.insert_mode_entered = false
            return true
          end
          return false
        end,
      },
      {
        id = "delete_text",
        title = "Delete Text (x, dd, dw, D)",
        instruction = "Delete: x (char), dd (line), dw (word), d$ or D (to end)",
        hint = "Try: dd to delete a line (you can undo with u)",
        auto_advance = 5,
      },
      {
        id = "change_text",
        title = "Change Text (cw, cc, C)",
        instruction = "Change: cw (word), cc (line), C (to end) - deletes and enters insert",
        hint = "Try: cw on a word, type new text, Esc",
        auto_advance = 5,
      },
      {
        id = "yank_paste",
        title = "Copy & Paste (yy, yw, p, P)",
        instruction = "Yank: yy (line), yw (word). Paste: p (after), P (before)",
        hint = "Try: yy to copy line, then p to paste below",
        auto_advance = 5,
      },
      {
        id = "undo_redo",
        title = "Undo & Redo (u, Ctrl+r)",
        instruction = "Undo with u, redo with Ctrl+r. Repeat last action with .",
        hint = "Make changes, then u to undo, Ctrl+r to redo",
        auto_advance = 4,
      },
      {
        id = "replace_char",
        title = "Replace (r, R)",
        instruction = "Replace: r{char} (single char), R (replace mode)",
        hint = "Try: r followed by a character to replace",
        auto_advance = 4,
      },
    },
  },

  -- MODULE 3: Visual Mode
  {
    name = "Visual Mode",
    description = "Select and manipulate text visually",
    tasks = {
      {
        id = "visual_char",
        title = "Character Selection (v)",
        instruction = "Press v to start visual mode, move to select, then d/y/c",
        hint = "Try: v then move with w or l, then y to copy",
        detect = function()
          local mode = vim.api.nvim_get_mode().mode
          if mode == "v" then
            state.visual_mode_entered = true
          end
          if state.visual_mode_entered and mode == "n" then
            state.visual_mode_entered = false
            return true
          end
          return false
        end,
      },
      {
        id = "visual_line",
        title = "Line Selection (V)",
        instruction = "Press V to select whole lines, move with j/k",
        hint = "Try: V then j to select 2 lines, then d to delete",
        detect = function()
          local mode = vim.api.nvim_get_mode().mode
          return mode == "V"
        end,
        auto_advance = 4,
      },
      {
        id = "visual_block",
        title = "Block Selection (Ctrl+v)",
        instruction = "Press Ctrl+v for block/column selection",
        hint = "Select a column, then I to insert on all lines",
        auto_advance = 5,
      },
      {
        id = "visual_actions",
        title = "Visual Actions (>, <, =)",
        instruction = "In visual: > (indent), < (unindent), = (auto-format)",
        hint = "Select lines with V, then > to indent",
        auto_advance = 5,
      },
    },
  },

  -- MODULE 4: Search
  {
    name = "Search & Replace",
    description = "Find and replace text efficiently",
    tasks = {
      {
        id = "search_forward",
        title = "Search Forward (/)",
        instruction = "Type /pattern then Enter to search. Use n/N for next/prev",
        hint = "Try: /def to find 'def', then n for next match",
        detect = function()
          local search = vim.fn.getreg("/")
          if search and search ~= "" and search ~= state.last_search then
            state.last_search = search
            return true
          end
          return false
        end,
      },
      {
        id = "search_word",
        title = "Search Word Under Cursor (* and #)",
        instruction = "Press * to search word forward, # for backward",
        hint = "Put cursor on a word, press * to find next occurrence",
        auto_advance = 4,
      },
      {
        id = "search_replace",
        title = "Search & Replace (:s)",
        instruction = "Replace: :s/old/new/ (line), :%s/old/new/g (file)",
        hint = "Try: :%s/result/output/g to replace all 'result' with 'output'",
        auto_advance = 6,
      },
      {
        id = "clear_search",
        title = "Clear Search Highlight",
        instruction = "Press <leader>ur or :noh to clear search highlights",
        hint = "Space + u + r clears highlights",
        auto_advance = 4,
      },
    },
  },

  -- MODULE 5: Text Objects
  {
    name = "Text Objects",
    description = "Power editing with inner/around motions",
    tasks = {
      {
        id = "inner_word",
        title = "Inner Word (ciw, diw, yiw)",
        instruction = "ciw = change inner word, diw = delete, yiw = yank",
        hint = "Put cursor anywhere in a word, type ciw to change it",
        auto_advance = 5,
      },
      {
        id = "inner_quotes",
        title = "Inner Quotes (ci\", ci')",
        instruction = "ci\" changes text inside quotes, di\" deletes it",
        hint = "Find a string in quotes, type ci\" to change inside",
        auto_advance = 5,
      },
      {
        id = "inner_parens",
        title = "Inner Brackets (ci(, ci[, ci{)",
        instruction = "ci( changes inside parentheses, works with [], {}",
        hint = "Find (something), type ci( to change inside",
        auto_advance = 5,
      },
      {
        id = "around_objects",
        title = "Around Objects (da\", da()",
        instruction = "da\" deletes including quotes, da( includes parens",
        hint = "Around includes the delimiters, inner doesn't",
        auto_advance = 5,
      },
      {
        id = "function_objects",
        title = "Function Objects (af, if)",
        instruction = "vaf selects around function, vif selects inner function",
        hint = "Put cursor in a function, try vaf to select it",
        auto_advance = 5,
      },
    },
  },

  -- MODULE 6: File Navigation (LazyVim)
  {
    name = "File Navigation",
    description = "Navigate files and buffers with LazyVim",
    tasks = {
      {
        id = "file_explorer",
        title = "File Explorer (<leader>e)",
        instruction = "Press <leader>e (Space+e) to toggle file explorer",
        hint = "Use j/k to navigate, Enter to open file",
        detect = function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")
            if ft == "neo-tree" or ft == "NvimTree" then
              return true
            end
          end
          return false
        end,
      },
      {
        id = "find_files",
        title = "Find Files (<leader>ff)",
        instruction = "Press <leader>ff (Space+f+f) to fuzzy find files",
        hint = "Type part of filename to filter, Enter to open",
        auto_advance = 5,
      },
      {
        id = "recent_files",
        title = "Recent Files (<leader>fr)",
        instruction = "Press <leader>fr for recently opened files",
        hint = "Quick way to switch between recent files",
        auto_advance = 4,
      },
      {
        id = "grep_files",
        title = "Search in Files (<leader>sg)",
        instruction = "Press <leader>sg to search text in all files (live grep)",
        hint = "Type text to search across entire project",
        auto_advance = 5,
      },
      {
        id = "open_main",
        title = "Open Main File",
        instruction = "Use file explorer or <leader>ff to open main file",
        hint = "Find and open main.py, main.go, or index.js",
        detect = function()
          local name = vim.api.nvim_buf_get_name(0)
          return name:match("main%.") ~= nil or name:match("index%.") ~= nil
        end,
      },
      {
        id = "open_utils",
        title = "Open Another File",
        instruction = "Open the utils/helpers file using any method",
        hint = "<leader>ff then type 'utils' or 'helpers'",
        detect = function()
          local name = vim.api.nvim_buf_get_name(0)
          return name:match("utils") ~= nil or name:match("helpers") ~= nil
        end,
      },
    },
  },

  -- MODULE 7: Buffers & Windows
  {
    name = "Buffers & Windows",
    description = "Manage multiple files and splits",
    tasks = {
      {
        id = "switch_buffer",
        title = "Switch Buffers (Shift+h/l)",
        instruction = "Press Shift+h for previous buffer, Shift+l for next",
        hint = "Open multiple files first, then use Shift+h/l",
        detect = function()
          local buf = vim.api.nvim_get_current_buf()
          if state.last_buffer and buf ~= state.last_buffer then
            state.last_buffer = buf
            return true
          end
          state.last_buffer = buf
          return false
        end,
      },
      {
        id = "buffer_list",
        title = "Buffer List (<leader>fb)",
        instruction = "Press <leader>fb to see all open buffers",
        hint = "Select a buffer from the list to switch",
        auto_advance = 4,
      },
      {
        id = "close_buffer",
        title = "Close Buffer (<leader>bd)",
        instruction = "Press <leader>bd to close current buffer",
        hint = "Closes file but keeps window open",
        auto_advance = 4,
      },
      {
        id = "split_vertical",
        title = "Vertical Split (<leader>|)",
        instruction = "Press <leader>| (Space+|) to split vertically",
        hint = "Creates side-by-side windows",
        detect = function()
          return #vim.api.nvim_list_wins() >= 2
        end,
      },
      {
        id = "split_horizontal",
        title = "Horizontal Split (<leader>-)",
        instruction = "Press <leader>- (Space+-) to split horizontally",
        hint = "Creates stacked windows",
        detect = function()
          return #vim.api.nvim_list_wins() >= 2
        end,
      },
      {
        id = "navigate_windows",
        title = "Navigate Windows (Ctrl+hjkl)",
        instruction = "Use Ctrl+h/j/k/l to move between windows",
        hint = "Create a split first, then navigate between them",
        auto_advance = 4,
      },
      {
        id = "close_window",
        title = "Close Window (<leader>wd)",
        instruction = "Press <leader>wd to close current window",
        hint = "Only closes window, buffer stays open",
        auto_advance = 3,
      },
    },
  },

  -- MODULE 8: LSP Features
  {
    name = "LSP & Code Intelligence",
    description = "Use language server features",
    tasks = {
      {
        id = "hover_docs",
        title = "Hover Documentation (K)",
        instruction = "Press K on a function/variable to see documentation",
        hint = "Put cursor on 'add' function and press K",
        auto_advance = 4,
      },
      {
        id = "goto_definition",
        title = "Go to Definition (gd)",
        instruction = "Press gd on a function call to jump to its definition",
        hint = "Find where a function is called, press gd",
        auto_advance = 5,
      },
      {
        id = "find_references",
        title = "Find References (gr)",
        instruction = "Press gr to find all references to symbol under cursor",
        hint = "Shows everywhere the function/variable is used",
        auto_advance = 5,
      },
      {
        id = "code_actions",
        title = "Code Actions (<leader>ca)",
        instruction = "Press <leader>ca to see available code actions",
        hint = "LSP suggestions for fixes and refactoring",
        auto_advance = 4,
      },
      {
        id = "rename_symbol",
        title = "Rename Symbol (<leader>cr)",
        instruction = "Press <leader>cr to rename a symbol across files",
        hint = "Smart rename that updates all references",
        auto_advance = 5,
      },
      {
        id = "diagnostics",
        title = "Navigate Diagnostics (]d, [d)",
        instruction = "Press ]d for next error/warning, [d for previous",
        hint = "Quick way to jump between issues",
        auto_advance = 4,
      },
      {
        id = "format_code",
        title = "Format Code (<leader>cf)",
        instruction = "Press <leader>cf to format the current file",
        hint = "Auto-formats according to language standards",
        auto_advance = 4,
      },
    },
  },

  -- MODULE 9: Git Integration
  {
    name = "Git Integration",
    description = "Version control with LazyVim",
    tasks = {
      {
        id = "lazygit",
        title = "Open Lazygit (<leader>gg)",
        instruction = "Press <leader>gg to open Lazygit UI",
        hint = "Full git interface - stage, commit, push, etc.",
        auto_advance = 5,
      },
      {
        id = "git_blame",
        title = "Git Blame (<leader>gb)",
        instruction = "Press <leader>gb to see who wrote each line",
        hint = "Shows commit author and date for each line",
        auto_advance = 4,
      },
      {
        id = "git_hunks",
        title = "Navigate Git Changes (]h, [h)",
        instruction = "Press ]h to jump to next change, [h for previous",
        hint = "Quickly navigate through uncommitted changes",
        auto_advance = 4,
      },
      {
        id = "stage_hunk",
        title = "Stage Hunk (<leader>ghs)",
        instruction = "Press <leader>ghs to stage current change",
        hint = "Stage individual changes without staging whole file",
        auto_advance = 5,
      },
      {
        id = "preview_hunk",
        title = "Preview Hunk (<leader>ghp)",
        instruction = "Press <leader>ghp to preview the current change",
        hint = "See what changed before staging",
        auto_advance = 4,
      },
    },
  },

  -- MODULE 10: Terminal
  {
    name = "Terminal",
    description = "Use the integrated terminal",
    tasks = {
      {
        id = "open_terminal",
        title = "Open Terminal (Ctrl+/ or <leader>ft)",
        instruction = "Press Ctrl+/ or <leader>ft to open terminal",
        hint = "Integrated terminal at project root",
        detect = function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
              return true
            end
          end
          return false
        end,
      },
      {
        id = "terminal_mode",
        title = "Terminal Mode",
        instruction = "In terminal: type commands. Press Esc Esc to exit terminal mode",
        hint = "Esc Esc returns to normal mode in terminal",
        auto_advance = 4,
      },
      {
        id = "run_project",
        title = "Run Your Project",
        instruction = "In terminal, run the project command shown below",
        hint = "Command will be shown based on project type",
        show_command = true,
        auto_advance = 8,
      },
      {
        id = "close_terminal",
        title = "Close Terminal",
        instruction = "Press Ctrl+/ again to toggle terminal closed",
        hint = "Or type 'exit' in the terminal",
        detect = function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
              return false
            end
          end
          return state.completed_tasks["open_terminal"] == true
        end,
      },
    },
  },

  -- MODULE 11: UI & Extras
  {
    name = "UI & Extras",
    description = "Toggles, tabs, and useful extras",
    tasks = {
      {
        id = "toggle_format",
        title = "Toggle Format on Save (<leader>uf)",
        instruction = "Press <leader>uf to toggle auto-format on save",
        hint = "Useful when you want to control formatting",
        auto_advance = 3,
      },
      {
        id = "toggle_numbers",
        title = "Toggle Line Numbers (<leader>ul)",
        instruction = "Press <leader>ul to toggle line numbers",
        hint = "Toggle between absolute and no line numbers",
        auto_advance = 3,
      },
      {
        id = "toggle_relative",
        title = "Toggle Relative Numbers (<leader>uL)",
        instruction = "Press <leader>uL to toggle relative line numbers",
        hint = "Relative numbers help with motions like 5j",
        auto_advance = 3,
      },
      {
        id = "which_key",
        title = "Which Key (just press <leader>)",
        instruction = "Press <leader> (Space) and wait to see all keymaps",
        hint = "Which-key shows available commands",
        auto_advance = 4,
      },
      {
        id = "search_keymaps",
        title = "Search Keymaps (<leader>sk)",
        instruction = "Press <leader>sk to search all keybindings",
        hint = "Find any keybinding by description",
        auto_advance = 4,
      },
      {
        id = "command_palette",
        title = "Command Palette (<leader>sc)",
        instruction = "Press <leader>sc to search all commands",
        hint = "Like VS Code's Ctrl+Shift+P",
        auto_advance = 4,
      },
    },
  },
}

-- Base path for practice projects
local function get_projects_base()
  return vim.fn.stdpath("data") .. "/lazyvim-belcaries-projects"
end

-- Create a project from template
local function create_project(project_type)
  local template = templates[project_type]
  if not template then
    vim.notify("Unknown project type: " .. project_type, vim.log.levels.ERROR)
    return nil
  end

  local base_path = get_projects_base()
  local project_path = base_path .. "/" .. project_type .. "-practice"

  vim.fn.mkdir(project_path, "p")

  for filename, content in pairs(template.files) do
    local filepath = project_path .. "/" .. filename
    local dir = vim.fn.fnamemodify(filepath, ":h")
    vim.fn.mkdir(dir, "p")

    local file = io.open(filepath, "w")
    if file then
      file:write(content)
      file:close()
    end
  end

  return project_path
end

-- Get current task
local function get_current_task()
  local module = practice_modules[state.current_module]
  if not module then return nil end
  return module.tasks[state.current_task]
end

-- Count total tasks
local function count_total_tasks()
  local total = 0
  for _, module in ipairs(practice_modules) do
    total = total + #module.tasks
  end
  return total
end

-- Get task number across all modules
local function get_global_task_number()
  local num = 0
  for i = 1, state.current_module - 1 do
    num = num + #practice_modules[i].tasks
  end
  return num + state.current_task
end

-- Create instruction popup
local function show_instruction()
  -- Close existing popup
  if state.popup_win and vim.api.nvim_win_is_valid(state.popup_win) then
    vim.api.nvim_win_close(state.popup_win, true)
  end

  local task = get_current_task()
  if not task then return end

  local module = practice_modules[state.current_module]
  local global_num = get_global_task_number()
  local total = count_total_tasks()

  local lines = {
    "",
    string.format("  MODULE %d: %s", state.current_module, module.name),
    "  " .. string.rep("=", 45),
    "",
    string.format("  Task %d/%d: %s", global_num, total, task.title),
    "",
    "  " .. string.rep("-", 45),
    "",
    "  " .. task.instruction,
    "",
    "  HINT: " .. task.hint,
    "",
  }

  if task.show_command and state.project_type then
    local template = templates[state.project_type]
    if template then
      table.insert(lines, "  COMMAND: " .. (template.run_command or ""))
      table.insert(lines, "")
    end
  end

  table.insert(lines, "  " .. string.rep("-", 45))
  table.insert(lines, "  s = skip | n = next | p = prev | q = quit")
  table.insert(lines, "")

  -- Progress bar
  local progress = math.floor((global_num / total) * 30)
  local bar = "[" .. string.rep("=", progress) .. string.rep(" ", 30 - progress) .. "]"
  table.insert(lines, "  " .. bar .. string.format(" %d%%", math.floor(global_num / total * 100)))
  table.insert(lines, "")

  local width = 55
  local height = #lines
  local ui = vim.api.nvim_list_uis()[1]
  local col = ui.width - width - 2
  local row = 1

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = " LazyVim Practice ",
    title_pos = "center",
    focusable = false,
  }

  state.popup_win = vim.api.nvim_open_win(buf, false, win_opts)
  state.popup_buf = buf
end

-- Advance to next task
local function next_task()
  state.current_task = state.current_task + 1

  local module = practice_modules[state.current_module]
  if state.current_task > #module.tasks then
    state.current_task = 1
    state.current_module = state.current_module + 1

    if state.current_module > #practice_modules then
      M.complete_practice()
      return
    end

    local new_module = practice_modules[state.current_module]
    vim.notify("Starting: " .. new_module.name, vim.log.levels.INFO)
  end

  show_instruction()
end

-- Go to previous task
local function prev_task()
  state.current_task = state.current_task - 1

  if state.current_task < 1 then
    state.current_module = state.current_module - 1
    if state.current_module < 1 then
      state.current_module = 1
      state.current_task = 1
    else
      state.current_task = #practice_modules[state.current_module].tasks
    end
  end

  show_instruction()
end

-- Check task completion
local function check_task_completion()
  if not state.active then return end

  local task = get_current_task()
  if not task then return end

  if task.detect and task.detect() then
    state.completed_tasks[task.id] = true
    state.total_completed = state.total_completed + 1
    vim.notify("Completed: " .. task.title, vim.log.levels.INFO)
    vim.defer_fn(next_task, 500)
  end
end

-- Auto-advance timer
local auto_advance_timer = nil

local function setup_auto_advance(task)
  if auto_advance_timer then
    vim.fn.timer_stop(auto_advance_timer)
    auto_advance_timer = nil
  end

  if task.auto_advance then
    auto_advance_timer = vim.fn.timer_start(task.auto_advance * 1000, function()
      vim.schedule(function()
        if state.active and get_current_task() == task then
          state.completed_tasks[task.id] = true
          state.total_completed = state.total_completed + 1
          next_task()
        end
      end)
    end)
  end
end

-- Setup autocommands for detection
local function setup_autocommands()
  state.autocommand_group = vim.api.nvim_create_augroup("BelcariesPractice", { clear = true })

  local events = {
    "BufEnter", "WinEnter", "CursorMoved", "CursorMovedI",
    "BufWinEnter", "TermOpen", "TermClose", "ModeChanged",
  }

  for _, event in ipairs(events) do
    vim.api.nvim_create_autocmd(event, {
      group = state.autocommand_group,
      callback = function()
        vim.defer_fn(function()
          check_task_completion()
          local task = get_current_task()
          if task then
            setup_auto_advance(task)
          end
        end, 100)
      end,
    })
  end

  -- Global practice keymaps
  vim.keymap.set("n", "s", function()
    if state.active then M.skip_task() end
  end, { desc = "Skip practice task" })

  vim.keymap.set("n", "<C-n>", function()
    if state.active then next_task() end
  end, { desc = "Next practice task" })

  vim.keymap.set("n", "<C-p>", function()
    if state.active then prev_task() end
  end, { desc = "Previous practice task" })
end

-- Clear autocommands
local function clear_autocommands()
  if state.autocommand_group then
    vim.api.nvim_del_augroup_by_id(state.autocommand_group)
    state.autocommand_group = nil
  end
  if auto_advance_timer then
    vim.fn.timer_stop(auto_advance_timer)
    auto_advance_timer = nil
  end
end

-- Start practice
function M.start(project_type)
  project_type = project_type or "python"

  local project_path = create_project(project_type)
  if not project_path then return end

  -- Initialize state
  state.active = true
  state.project_type = project_type
  state.project_path = project_path
  state.current_module = 1
  state.current_task = 1
  state.completed_tasks = {}
  state.total_completed = 0
  state.last_cursor_pos = nil
  state.last_buffer = nil
  state.last_search = nil

  -- Change to project directory
  vim.cmd("cd " .. project_path)

  -- Open main file
  local main_file = project_path .. "/" .. (project_type == "javascript" and "index.js" or "main." .. (project_type == "go" and "go" or "py"))
  vim.cmd("edit " .. main_file)

  -- Setup detection
  setup_autocommands()

  -- Show first instruction
  show_instruction()

  local template = templates[project_type]
  vim.notify(
    string.format("Practice Started: %s\n%d modules, %d tasks total\nFollow the instructions!",
      template.name, #practice_modules, count_total_tasks()),
    vim.log.levels.INFO
  )
end

-- Skip current task
function M.skip_task()
  if not state.active then return end
  local task = get_current_task()
  vim.notify("Skipped: " .. task.title, vim.log.levels.WARN)
  next_task()
end

-- Complete practice
function M.complete_practice()
  state.active = false
  clear_autocommands()

  if state.popup_win and vim.api.nvim_win_is_valid(state.popup_win) then
    vim.api.nvim_win_close(state.popup_win, true)
  end

  local total = count_total_tasks()
  local pct = math.floor(state.total_completed / total * 100)

  local lines = {
    "",
    "  PRACTICE COMPLETE!",
    "  ==================",
    "",
    string.format("  Completed: %d / %d tasks (%d%%)", state.total_completed, total, pct),
    "",
    "  You've practiced:",
    "",
    "  - Basic movement (hjkl, words, lines)",
    "  - Editing (insert, delete, change, yank)",
    "  - Visual mode (char, line, block)",
    "  - Search and replace",
    "  - Text objects (inner/around)",
    "  - File navigation (explorer, telescope)",
    "  - Buffers and window splits",
    "  - LSP features (hover, goto, rename)",
    "  - Git integration",
    "  - Terminal usage",
    "  - UI toggles and extras",
    "",
    "  You now have a solid LazyVim workflow!",
    "",
    "  Press <leader>ht for tutorial reference",
    "  Press <leader>hp to practice again",
    "",
  }

  local width = 50
  local height = #lines
  local ui = vim.api.nvim_list_uis()[1]
  local col = math.floor((ui.width - width) / 2)
  local row = math.floor((ui.height - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = " Congratulations! ",
    title_pos = "center",
  })

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true })

  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true })
end

-- Stop practice
function M.stop()
  state.active = false
  clear_autocommands()

  if state.popup_win and vim.api.nvim_win_is_valid(state.popup_win) then
    vim.api.nvim_win_close(state.popup_win, true)
  end

  vim.notify("Practice stopped", vim.log.levels.INFO)
end

-- Project selection menu
function M.select_project()
  local lines = {
    "",
    "  COMPREHENSIVE LAZYVIM PRACTICE",
    "  ===============================",
    "",
    "  Choose a project to practice with:",
    "",
    "  1. Python   - Calculator App",
    "  2. Go       - HTTP Server",
    "  3. JavaScript - Todo App",
    "",
    "  You will practice ALL LazyVim skills:",
    "  - Movement, editing, visual mode",
    "  - Search, text objects",
    "  - File navigation, buffers, windows",
    "  - LSP, Git, Terminal",
    "",
    string.format("  Total: %d modules, %d tasks", #practice_modules, count_total_tasks()),
    "",
    "  Press 1, 2, or 3 to start",
    "  Press q to cancel",
    "",
  }

  local width = 45
  local height = #lines
  local ui = vim.api.nvim_list_uis()[1]
  local col = math.floor((ui.width - width) / 2)
  local row = math.floor((ui.height - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = " Practice Mode ",
    title_pos = "center",
  })

  local function close_and_start(project_type)
    vim.api.nvim_win_close(win, true)
    if project_type then
      M.start(project_type)
    end
  end

  vim.keymap.set("n", "1", function() close_and_start("python") end, { buffer = buf, silent = true })
  vim.keymap.set("n", "2", function() close_and_start("go") end, { buffer = buf, silent = true })
  vim.keymap.set("n", "3", function() close_and_start("javascript") end, { buffer = buf, silent = true })
  vim.keymap.set("n", "q", function() close_and_start(nil) end, { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", function() close_and_start(nil) end, { buffer = buf, silent = true })
end

-- Check if practice is active
function M.is_active()
  return state.active
end

-- Get progress
function M.get_progress()
  return {
    module = state.current_module,
    task = state.current_task,
    completed = state.total_completed,
    total = count_total_tasks(),
  }
end

return M
