-- LazyVim Belcaries Edition - Real Developer Workflow Practice
-- Tasks complete ONLY when you perform the required action
-- Based on daily dev workflows: navigation, editing, refactoring, search, multi-file work

local M = {}

-- Bookmark file path
local bookmark_file = vim.fn.stdpath("data") .. "/lazyvim-belcaries-bookmark.json"

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
  -- Detection control
  task_ready = false,        -- Set by setup(), checked by detect()
  transitioning = false,     -- Blocks detection during task transitions
  completion_pending = false, -- Blocks multiple completion calls
  -- Detection helpers
  initial_buffer_content = nil,
  initial_line_count = nil,
  target_achieved = false,
}

-- ============================================================================
-- BOOKMARK SYSTEM - Save/Load progress
-- ============================================================================

local function save_bookmark()
  local data = {
    current_module = state.current_module,
    current_task = state.current_task,
    total_completed = state.total_completed,
    project_type = state.project_type,
    timestamp = os.date("%Y-%m-%d %H:%M:%S"),
  }
  local json = vim.fn.json_encode(data)
  local file = io.open(bookmark_file, "w")
  if file then
    file:write(json)
    file:close()
    vim.notify("📌 Progress saved: Module " .. state.current_module .. ", Task " .. state.current_task, vim.log.levels.INFO)
  end
end

local function load_bookmark()
  local file = io.open(bookmark_file, "r")
  if file then
    local content = file:read("*all")
    file:close()
    local ok, data = pcall(vim.fn.json_decode, content)
    if ok and data then
      return data
    end
  end
  return nil
end

local function clear_bookmark()
  os.remove(bookmark_file)
end

function M.bookmark()
  if state.active then
    save_bookmark()
  else
    vim.notify("No active practice session to bookmark", vim.log.levels.WARN)
  end
end

function M.has_bookmark()
  return load_bookmark() ~= nil
end

-- ============================================================================
-- PROJECT TEMPLATE - Realistic Python codebase for practice
-- ============================================================================

local templates = {
  python = {
    name = "Task Manager API",
    description = "A realistic Python project with common patterns to practice on",
    files = {
      ["app/main.py"] = [[
"""Task Manager API - Main Application Entry Point"""
from app.models import Task, User, Priority
from app.database import DatabaseConnection
from app.utils import validate_input, format_response

# Global database connection - REFACTOR: should use dependency injection
db = DatabaseConnection("tasks.db")

def create_task(title, description, user_id, priority=Priority.MEDIUM):
    """Create a new task in the database.

    Args:
        title: Task title (required)
        description: Task description (required)
        user_id: ID of the user creating the task
        priority: Task priority level (default: MEDIUM)

    Returns:
        dict: Created task data or error response
    """
    if not validate_input(title) or not validate_input(description):
        return format_response(error="Invalid input provided")

    task = Task(
        title=title,
        description=description,
        user_id=user_id,
        priority=priority,
        status="pending"
    )

    result = db.insert("tasks", task.to_dict())
    return format_response(data=result)

def get_task(task_id):
    """Retrieve a task by ID."""
    task_data = db.find_one("tasks", {"id": task_id})
    if not task_data:
        return format_response(error="Task not found")
    return format_response(data=task_data)

def update_task(task_id, updates):
    """Update an existing task."""
    existing = db.find_one("tasks", {"id": task_id})
    if not existing:
        return format_response(error="Task not found")

    result = db.update("tasks", {"id": task_id}, updates)
    return format_response(data=result)

def delete_task(task_id):
    """Delete a task by ID."""
    result = db.delete("tasks", {"id": task_id})
    return format_response(data={"deleted": result})

def list_tasks(user_id=None, status=None, priority=None):
    """List tasks with optional filters."""
    filters = {}
    if user_id:
        filters["user_id"] = user_id
    if status:
        filters["status"] = status
    if priority:
        filters["priority"] = priority

    tasks = db.find_many("tasks", filters)
    return format_response(data=tasks)

# DEPRECATED: Old function - delete this
def old_get_all_tasks():
    """This function is deprecated and should be removed."""
    return db.find_many("tasks", {})

# TODO: Move this helper to utils.py
def calculate_completion_rate(user_id):
    """Calculate task completion rate for a user."""
    all_tasks = db.find_many("tasks", {"user_id": user_id})
    if not all_tasks:
        return 0.0
    completed = [t for t in all_tasks if t["status"] == "completed"]
    return len(completed) / len(all_tasks) * 100

if __name__ == "__main__":
    print("Task Manager API")
    print("Use: from app.main import create_task, get_task, list_tasks")
]],
      ["app/models.py"] = [[
"""Data models for the Task Manager API"""
from dataclasses import dataclass
from enum import Enum
from datetime import datetime
from typing import Optional

class Priority(Enum):
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    URGENT = 4

class Status(Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

@dataclass
class Task:
    """Represents a task in the system."""
    title: str
    description: str
    user_id: int
    priority: Priority = Priority.MEDIUM
    status: str = "pending"
    id: Optional[int] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    def to_dict(self):
        """Convert task to dictionary."""
        return {
            "id": self.id,
            "title": self.title,
            "description": self.description,
            "user_id": self.user_id,
            "priority": self.priority.value if isinstance(self.priority, Priority) else self.priority,
            "status": self.status,
            "created_at": str(self.created_at) if self.created_at else None,
            "updated_at": str(self.updated_at) if self.updated_at else None,
        }

    @classmethod
    def from_dict(cls, data):
        """Create task from dictionary."""
        return cls(
            id=data.get("id"),
            title=data["title"],
            description=data["description"],
            user_id=data["user_id"],
            priority=Priority(data.get("priority", 2)),
            status=data.get("status", "pending"),
        )

@dataclass
class User:
    """Represents a user in the system."""
    username: str
    email: str
    id: Optional[int] = None
    created_at: Optional[datetime] = None

    def to_dict(self):
        """Convert user to dictionary."""
        return {
            "id": self.id,
            "username": self.username,
            "email": self.email,
            "created_at": str(self.created_at) if self.created_at else None,
        }

# PASTE_TARGET: Helper functions should go here
]],
      ["app/utils.py"] = [[
"""Utility functions for the Task Manager API"""
import re
from typing import Any, Dict, Optional

def validate_input(value: str) -> bool:
    """Validate that input is not empty or just whitespace.

    Args:
        value: String to validate

    Returns:
        bool: True if valid, False otherwise
    """
    if not value:
        return False
    if not isinstance(value, str):
        return False
    return len(value.strip()) > 0

def validate_email(email: str) -> bool:
    """Validate email format using regex."""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))

def format_response(data: Any = None, error: Optional[str] = None) -> Dict:
    """Format API response consistently.

    Args:
        data: Response data (if successful)
        error: Error message (if failed)

    Returns:
        dict: Formatted response with success flag
    """
    if error:
        return {
            "success": False,
            "error": error,
            "data": None
        }
    return {
        "success": True,
        "error": None,
        "data": data
    }

def sanitize_string(value: str) -> str:
    """Remove potentially dangerous characters from string."""
    if not value:
        return ""
    # Remove HTML tags
    value = re.sub(r'<[^>]+>', '', value)
    # Remove special characters but keep basic punctuation
    value = re.sub(r'[^\w\s\-.,!?]', '', value)
    return value.strip()

def paginate_results(items: list, page: int = 1, per_page: int = 10) -> Dict:
    """Paginate a list of items.

    Args:
        items: List of items to paginate
        page: Page number (1-indexed)
        per_page: Items per page

    Returns:
        dict: Paginated results with metadata
    """
    total = len(items)
    start = (page - 1) * per_page
    end = start + per_page

    return {
        "items": items[start:end],
        "page": page,
        "per_page": per_page,
        "total": total,
        "pages": (total + per_page - 1) // per_page
    }
]],
      ["app/database.py"] = [[
"""Database connection and operations for Task Manager API"""
from typing import Dict, List, Optional, Any

class DatabaseConnection:
    """Simple database interface (mock implementation for practice)."""

    def __init__(self, db_path: str):
        """Initialize database connection.

        Args:
            db_path: Path to the database file
        """
        self.db_path = db_path
        self._connected = False
        self._data = {}  # In-memory storage for mock

    def connect(self) -> bool:
        """Establish database connection."""
        # Mock implementation
        self._connected = True
        return True

    def disconnect(self) -> None:
        """Close database connection."""
        self._connected = False

    def insert(self, collection: str, document: Dict) -> Dict:
        """Insert a document into a collection.

        Args:
            collection: Name of the collection
            document: Document to insert

        Returns:
            dict: Inserted document with ID
        """
        if collection not in self._data:
            self._data[collection] = []

        # Generate ID
        doc_id = len(self._data[collection]) + 1
        document["id"] = doc_id

        self._data[collection].append(document)
        return document

    def find_one(self, collection: str, query: Dict) -> Optional[Dict]:
        """Find a single document matching the query.

        Args:
            collection: Name of the collection
            query: Query filters

        Returns:
            dict or None: Matching document or None
        """
        if collection not in self._data:
            return None

        for doc in self._data[collection]:
            if all(doc.get(k) == v for k, v in query.items()):
                return doc
        return None

    def find_many(self, collection: str, query: Dict) -> List[Dict]:
        """Find all documents matching the query.

        Args:
            collection: Name of the collection
            query: Query filters

        Returns:
            list: List of matching documents
        """
        if collection not in self._data:
            return []

        if not query:
            return self._data[collection]

        results = []
        for doc in self._data[collection]:
            if all(doc.get(k) == v for k, v in query.items()):
                results.append(doc)
        return results

    def update(self, collection: str, query: Dict, updates: Dict) -> Optional[Dict]:
        """Update a document matching the query.

        Args:
            collection: Collection name
            query: Query to find document
            updates: Fields to update

        Returns:
            dict or None: Updated document or None
        """
        doc = self.find_one(collection, query)
        if doc:
            doc.update(updates)
            return doc
        return None

    def delete(self, collection: str, query: Dict) -> bool:
        """Delete a document matching the query.

        Args:
            collection: Collection name
            query: Query to find document

        Returns:
            bool: True if deleted, False otherwise
        """
        if collection not in self._data:
            return False

        for i, doc in enumerate(self._data[collection]):
            if all(doc.get(k) == v for k, v in query.items()):
                self._data[collection].pop(i)
                return True
        return False
]],
      ["tests/test_main.py"] = [[
"""Unit tests for the Task Manager API"""
import sys
sys.path.insert(0, '..')

from app.main import create_task, get_task, list_tasks, delete_task
from app.models import Priority

def test_create_task():
    """Test task creation."""
    result = create_task(
        title="Test Task",
        description="A test task description",
        user_id=1,
        priority=Priority.HIGH
    )
    assert result["success"] == True
    assert result["data"]["title"] == "Test Task"
    print("test_create_task: PASSED")

def test_create_task_invalid_input():
    """Test task creation with invalid input."""
    result = create_task(
        title="",
        description="Description",
        user_id=1
    )
    assert result["success"] == False
    assert "Invalid input" in result["error"]
    print("test_create_task_invalid_input: PASSED")

def test_get_task_not_found():
    """Test getting a non-existent task."""
    result = get_task(9999)
    assert result["success"] == False
    assert "not found" in result["error"]
    print("test_get_task_not_found: PASSED")

def test_list_tasks():
    """Test listing tasks."""
    result = list_tasks()
    assert result["success"] == True
    assert isinstance(result["data"], list)
    print("test_list_tasks: PASSED")

def test_delete_task():
    """Test task deletion."""
    # First create a task
    create_result = create_task(
        title="To Delete",
        description="This will be deleted",
        user_id=1
    )
    task_id = create_result["data"]["id"]

    # Then delete it
    delete_result = delete_task(task_id)
    assert delete_result["success"] == True
    print("test_delete_task: PASSED")

if __name__ == "__main__":
    print("Running Task Manager API Tests")
    print("=" * 40)
    test_create_task()
    test_create_task_invalid_input()
    test_get_task_not_found()
    test_list_tasks()
    test_delete_task()
    print("=" * 40)
    print("All tests passed!")
]],
      ["README.md"] = [[
# Task Manager API

A Python API for managing tasks - used for LazyVim practice.

## Project Structure

```
app/
├── main.py      - Main API functions (create, get, update, delete tasks)
├── models.py    - Data models (Task, User, Priority, Status)
├── utils.py     - Utility functions (validation, formatting)
└── database.py  - Database connection layer

tests/
└── test_main.py - Unit tests
```

## Practice Scenarios

This project is designed for practicing real dev workflows:

1. **Navigation** - Jump between files, find definitions
2. **Editing** - Delete deprecated code, change function names
3. **Refactoring** - Move helper functions between files
4. **Search** - Find all usages, search & replace
5. **Multi-file** - Compare implementations, split views

## Key Files to Practice On

- `app/main.py` - Has deprecated functions to delete, TODOs to move
- `app/models.py` - Has a PASTE_TARGET for moved code
- `app/utils.py` - Helper functions to understand
- `tests/test_main.py` - Navigate to test implementations
]],
    },
  },
}

-- ============================================================================
-- REAL DEVELOPER WORKFLOW MODULES
-- Each task detects specific actions - no time-based auto-advance!
-- ============================================================================

local practice_modules = {
  -- MODULE 1: Code Navigation (daily workflow)
  {
    name = "Code Navigation",
    description = "Navigate code like a pro - find definitions, references, symbols",
    tasks = {
      {
        id = "open_main",
        title = "Open the Main Module",
        instruction = "Use `<leader>ff` to find and open app/main.py",
        hint = "Press Space+f+f, then type 'main' and select app/main.py",
        setup = function()
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local name = vim.api.nvim_buf_get_name(0)
          return name:find("app/main%.py") ~= nil
        end,
      },
      {
        id = "goto_function",
        title = "Go to the create_task Function",
        instruction = "Use `/def create_task` to search and jump to the function definition (line 9)",
        hint = "Type /def create_task and press Enter. The function is on line 9",
        setup = function()
          state.initial_line = vim.api.nvim_win_get_cursor(0)[1]
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local line = vim.api.nvim_win_get_cursor(0)[1]
          -- Must have MOVED to lines 9-15 (the function signature area)
          return line >= 9 and line <= 15 and line ~= state.initial_line
        end,
      },
      {
        id = "hover_docs",
        title = "View Function Documentation",
        instruction = "Press `K` on the function name to see its docstring",
        hint = "Cursor on 'create_task', then press K (capital)",
        setup = function()
          -- Snapshot float count at task start
          state.initial_float_count = 0
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if win ~= state.popup_win then
              local config = vim.api.nvim_win_get_config(win)
              if config.relative ~= "" then
                state.initial_float_count = state.initial_float_count + 1
              end
            end
          end
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          -- SUCCESS: A new floating window appeared (hover docs)
          -- User can move cursor, position themselves - doesn't matter
          -- ONLY a new float triggers success
          local current_float_count = 0
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if win ~= state.popup_win then
              local config = vim.api.nvim_win_get_config(win)
              if config.relative ~= "" then
                current_float_count = current_float_count + 1
              end
            end
          end
          return current_float_count > state.initial_float_count
        end,
        -- No detect_fail: user can position, try things, only K success matters
      },
      {
        id = "goto_definition",
        title = "Jump to Definition",
        instruction = "Go to line 21 where `validate_input` is called, put cursor on it, press `gd` to jump to its definition",
        hint = "Type :21 to go to line 21, cursor on validate_input, then gd. Should open utils.py",
        setup = function()
          state.initial_file = vim.api.nvim_buf_get_name(0)
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local name = vim.api.nvim_buf_get_name(0)
          -- Must have CHANGED to utils.py
          return name:find("utils%.py") ~= nil and not state.initial_file:find("utils%.py")
        end,
      },
      {
        id = "go_back",
        title = "Jump Back",
        instruction = "Press `Ctrl+o` to jump back to where you were in main.py",
        hint = "Ctrl+o jumps to previous location in jump list",
        setup = function()
          state.initial_file = vim.api.nvim_buf_get_name(0)
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local name = vim.api.nvim_buf_get_name(0)
          -- Must have CHANGED back to main.py
          return name:find("main%.py") ~= nil and not state.initial_file:find("main%.py")
        end,
      },
      {
        id = "find_references",
        title = "Find All References",
        instruction = "Put cursor on `format_response` and press `gr` to find all places it's used",
        hint = "Navigate to format_response, then gr shows all references",
        setup = function()
          state.had_telescope = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")
            if ft == "TelescopePrompt" or ft == "qf" or ft == "trouble" then
              state.had_telescope = true
            end
          end
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          if state.had_telescope then return false end  -- Already had it open
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")
            if ft == "TelescopePrompt" or ft == "qf" or ft == "trouble" then
              return true
            end
          end
          return false
        end,
      },
    },
  },

  -- MODULE 2: Surgical Text Editing
  {
    name = "Surgical Editing",
    description = "Edit code precisely with text objects - the vim superpower",
    tasks = {
      {
        id = "find_deprecated",
        title = "Find the Deprecated Function",
        instruction = "In main.py, search for 'DEPRECATED' using `/DEPRECATED` (it's on line 69)",
        hint = "Type /DEPRECATED and press Enter. Should jump to line 69",
        setup = function()
          state.initial_line = vim.api.nvim_win_get_cursor(0)[1]
          state.initial_search = vim.fn.getreg("/") or ""
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local line = vim.api.nvim_win_get_cursor(0)[1]
          local search = vim.fn.getreg("/") or ""
          -- Must have searched for DEPRECATED (new search) OR moved to line 69-73
          local new_search = search:find("DEPRECATED") and not state.initial_search:find("DEPRECATED")
          local moved_to_target = line >= 69 and line <= 73 and state.initial_line < 60
          return new_search or moved_to_target
        end,
      },
      {
        id = "delete_comment_line",
        title = "Delete the DEPRECATED Comment",
        instruction = "Position on the '# DEPRECATED' line and delete it with `dd`",
        hint = "Press dd to delete the entire line",
        setup = function()
          state.initial_buffer_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          local had_it = state.initial_buffer_content and state.initial_buffer_content:find("# DEPRECATED:")
          return had_it and not content:find("# DEPRECATED:")
        end,
      },
      {
        id = "delete_function",
        title = "Delete the Deprecated Function",
        instruction = "Delete the entire `old_get_all_tasks` function using `dap` (delete around paragraph) or `V` + motion + `d`",
        hint = "Position inside the function, then dap deletes it. Or V to select lines, } to extend, d to delete",
        setup = function()
          state.initial_buffer_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          local had_it = state.initial_buffer_content and state.initial_buffer_content:find("def old_get_all_tasks")
          return had_it and not content:find("def old_get_all_tasks")
        end,
      },
      {
        id = "change_inner_string",
        title = "Change a String Value",
        instruction = "Go to line 39, find \"Task not found\", change it to \"Task does not exist\" using `ci\"`",
        hint = "Type :39 Enter, position cursor inside the quotes, ci\" deletes the text, type new text, Esc",
        setup = function()
          state.initial_buffer_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          -- Must be a NEW change (didn't have it before, has it now)
          local had_it = state.initial_buffer_content and state.initial_buffer_content:find("Task does not exist")
          return not had_it and content:find("Task does not exist")
        end,
      },
      {
        id = "change_word",
        title = "Change a Variable Name",
        instruction = "Go to line 53 in delete_task function, change 'result' to 'deleted_count' using `ciw`",
        hint = "Type :53 Enter, cursor on 'result', ciw deletes word, type 'deleted_count', Esc",
        setup = function()
          state.initial_buffer_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          -- Check if deleted_count is NEW in delete_task area
          local delete_section = content:match("def delete_task.-return format_response")
          local had_it = state.initial_buffer_content and state.initial_buffer_content:find("deleted_count")
          return not had_it and delete_section and delete_section:find("deleted_count")
        end,
      },
      {
        id = "undo_changes",
        title = "Undo Your Last Change",
        instruction = "Press `u` to undo the last change, then `Ctrl+r` to redo it",
        hint = "u undoes, Ctrl+r redoes",
        setup = function()
          state.initial_buffer_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          state.undo_count = 0
          state.task_ready = true
          -- Track undo events
          vim.api.nvim_create_autocmd({"TextChanged"}, {
            group = state.autocommand_group,
            buffer = 0,
            callback = function()
              if state.task_ready then
                state.undo_count = (state.undo_count or 0) + 1
              end
            end,
            once = false,
          })
        end,
        detect = function()
          if not state.task_ready then return false end
          -- Require at least 2 changes (undo + redo)
          return (state.undo_count or 0) >= 2
        end,
      },
    },
  },

  -- MODULE 3: Multi-file Refactoring
  {
    name = "Refactoring Workflow",
    description = "Move code between files - a daily dev task",
    tasks = {
      {
        id = "find_todo",
        title = "Find the TODO Comment",
        instruction = "Search for 'TODO' to find the helper function that needs to be moved (line 74)",
        hint = "Type /TODO and press Enter. Should jump to line 74",
        setup = function()
          state.initial_line = vim.api.nvim_win_get_cursor(0)[1]
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local line = vim.api.nvim_win_get_cursor(0)[1]
          -- Must MOVE to line 74-81 from elsewhere
          return line >= 74 and line <= 81 and state.initial_line < 70
        end,
      },
      {
        id = "select_function",
        title = "Select the Function to Move",
        instruction = "Select the entire `calculate_completion_rate` function with `V` then `}` or use `vaf` if treesitter is available",
        hint = "Go to 'def calculate', then V to start line select, } to extend to end of paragraph",
        setup = function()
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local mode = vim.api.nvim_get_mode().mode
          return mode == "V" or mode == "v"
        end,
      },
      {
        id = "yank_function",
        title = "Yank the Selected Function",
        instruction = "Press `y` to yank (copy) the selected function",
        hint = "After selecting with V, press y to yank",
        setup = function()
          state.initial_reg = vim.fn.getreg('"') or ""
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local reg = vim.fn.getreg('"') or ""
          -- Must be NEW yank containing the function
          return reg:find("def calculate_completion_rate") and not state.initial_reg:find("def calculate_completion_rate")
        end,
      },
      {
        id = "delete_original",
        title = "Delete the Original (Cut)",
        instruction = "Now delete the TODO comment and the function from main.py using `V` + motion + `d`",
        hint = "Or press gv to reselect, then d to delete. Also delete the TODO comment above it",
        setup = function()
          state.initial_buffer_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          local had_it = state.initial_buffer_content:find("def calculate_completion_rate")
          return had_it and not content:find("def calculate_completion_rate")
        end,
      },
      {
        id = "open_target_file",
        title = "Open the Target File",
        instruction = "Open app/models.py where we'll paste the function (use `<leader>ff` or file explorer)",
        hint = "Space+f+f then type 'models'",
        setup = function()
          state.initial_file = vim.api.nvim_buf_get_name(0)
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local name = vim.api.nvim_buf_get_name(0)
          return name:find("models%.py") ~= nil and not state.initial_file:find("models%.py")
        end,
      },
      {
        id = "find_paste_target",
        title = "Find Where to Paste",
        instruction = "Search for 'PASTE_TARGET' using `/PASTE` - it's on line 73 in models.py",
        hint = "Type /PASTE and press Enter. Should be on line 73",
        setup = function()
          state.initial_line = vim.api.nvim_win_get_cursor(0)[1]
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local line = vim.api.nvim_win_get_cursor(0)[1]
          -- Must MOVE to line 72-74
          return line >= 72 and line <= 74 and state.initial_line ~= line
        end,
      },
      {
        id = "paste_function",
        title = "Paste the Function",
        instruction = "Press `p` to paste the function below the PASTE_TARGET comment",
        hint = "Just press p in normal mode",
        setup = function()
          state.initial_buffer_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local name = vim.api.nvim_buf_get_name(0)
          if name:find("models%.py") then
            local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
            local had_it = state.initial_buffer_content:find("def calculate_completion_rate")
            return not had_it and content:find("def calculate_completion_rate")
          end
          return false
        end,
      },
    },
  },

  -- MODULE 4: Search & Replace
  {
    name = "Search & Replace",
    description = "Find and replace across files - essential for refactoring",
    tasks = {
      {
        id = "search_word",
        title = "Search Word Under Cursor",
        instruction = "Open main.py, put cursor on 'format_response' and press `*` to search for all occurrences",
        hint = "Navigate to format_response, then * searches for the word",
        setup = function()
          state.initial_search = vim.fn.getreg("/") or ""
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local search = vim.fn.getreg("/") or ""
          -- Must be a NEW search for format_response
          local has_format = search:find("format_response") or search:find("\\<format_response\\>")
          local had_format = state.initial_search:find("format_response") or state.initial_search:find("\\<format_response\\>")
          return has_format and not had_format
        end,
      },
      {
        id = "navigate_matches",
        title = "Navigate Between Matches",
        instruction = "Press `n` to go to next match, `N` for previous",
        hint = "n = next, N = previous match",
        setup = function()
          state.initial_line = vim.api.nvim_win_get_cursor(0)[1]
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local line = vim.api.nvim_win_get_cursor(0)[1]
          -- Must have MOVED from initial position
          return line ~= state.initial_line
        end,
      },
      {
        id = "clear_search",
        title = "Clear Search Highlight",
        instruction = "Press `<leader>ur` or type `:noh` to clear the search highlighting",
        hint = "Space+u+r or :noh Enter",
        setup = function()
          state.initial_hlsearch = vim.v.hlsearch
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          -- Must have been ON and now OFF
          return state.initial_hlsearch == 1 and vim.v.hlsearch == 0
        end,
      },
      {
        id = "replace_in_file",
        title = "Replace in Entire File",
        instruction = "Replace all 'task_id' with 'id' using `:%s/task_id/id/gc` (with confirmation)",
        hint = ":%s/task_id/id/gc - the 'c' flag asks for confirmation each time",
        setup = function()
          local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          local _, count = content:gsub("task_id", "")
          state.initial_task_id_count = count
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          local _, count = content:gsub("task_id", "")
          -- Must have REDUCED the count (at least one replacement)
          return count < state.initial_task_id_count
        end,
      },
      {
        id = "project_search",
        title = "Search Across All Files",
        instruction = "Use `<leader>sg` (live grep) to search for 'validate' across the entire project",
        hint = "Space+s+g opens live grep, type 'validate'",
        setup = function()
          state.had_telescope = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")
            if ft == "TelescopePrompt" then
              state.had_telescope = true
            end
          end
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          if state.had_telescope then return false end
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")
            if ft == "TelescopePrompt" then
              return true
            end
          end
          return false
        end,
      },
    },
  },

  -- MODULE 5: Multi-file Workflows
  {
    name = "Multi-file Work",
    description = "Work with multiple files efficiently - splits, buffers, tabs",
    tasks = {
      {
        id = "vertical_split",
        title = "Create Vertical Split",
        instruction = "Press `<leader>|` to create a vertical split",
        hint = "Space then | (pipe character)",
        setup = function()
          state.initial_win_count = #vim.api.nvim_list_wins()
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          -- Must have ADDED a new window
          return #vim.api.nvim_list_wins() > state.initial_win_count
        end,
      },
      {
        id = "open_in_split",
        title = "Open Different File in Split",
        instruction = "In the new split, open app/utils.py so you can see both files",
        hint = "Use <leader>ff in the new window",
        setup = function()
          state.initial_files = {}
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local name = vim.api.nvim_buf_get_name(buf)
            if name:find("utils%.py") then state.initial_files.utils = true end
          end
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          -- Must have opened utils.py that wasn't open before
          if state.initial_files.utils then return false end
          local files = {}
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local name = vim.api.nvim_buf_get_name(buf)
            if name:find("main%.py") then files.main = true end
            if name:find("utils%.py") then files.utils = true end
          end
          return files.main and files.utils
        end,
      },
      {
        id = "navigate_splits",
        title = "Navigate Between Splits",
        instruction = "Use `Ctrl+h` and `Ctrl+l` to move between the two windows",
        hint = "Ctrl+h = left window, Ctrl+l = right window",
        setup = function()
          state.initial_win = vim.api.nvim_get_current_win()
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          return state.initial_win and vim.api.nvim_get_current_win() ~= state.initial_win
        end,
      },
      {
        id = "close_split",
        title = "Close Current Split",
        instruction = "Close the current window with `<leader>wd`",
        hint = "Space+w+d closes window (buffer stays open)",
        setup = function()
          state.initial_win_count = #vim.api.nvim_list_wins()
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          -- Must have REDUCED window count
          return #vim.api.nvim_list_wins() < state.initial_win_count
        end,
      },
      {
        id = "buffer_switch",
        title = "Switch Between Buffers",
        instruction = "Use `<S-h>` and `<S-l>` (Shift+h/l) to switch between open buffers",
        hint = "Shift+h = previous buffer, Shift+l = next buffer",
        setup = function()
          state.initial_buf = vim.api.nvim_get_current_buf()
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          return state.initial_buf and vim.api.nvim_get_current_buf() ~= state.initial_buf
        end,
      },
      {
        id = "buffer_list",
        title = "View All Open Buffers",
        instruction = "Press `<leader>fb` to see all open buffers and select one",
        hint = "Space+f+b shows buffer picker",
        setup = function()
          state.had_telescope = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")
            if ft == "TelescopePrompt" then
              state.had_telescope = true
            end
          end
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          if state.had_telescope then return false end
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")
            if ft == "TelescopePrompt" then
              return true
            end
          end
          return false
        end,
      },
    },
  },

  -- MODULE 6: File Explorer & Project Navigation
  {
    name = "Project Navigation",
    description = "Navigate project structure with file explorer",
    tasks = {
      {
        id = "open_explorer",
        title = "Open File Explorer",
        instruction = "Press `<leader>e` to open the file explorer sidebar",
        hint = "Space+e toggles the file tree",
        setup = function()
          state.had_explorer = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")
            if ft == "neo-tree" or ft == "NvimTree" then
              state.had_explorer = true
            end
          end
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          if state.had_explorer then return false end
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
        id = "navigate_explorer",
        title = "Navigate to tests folder",
        instruction = "In the explorer, use `j/k` to navigate and find the 'tests' folder",
        hint = "j = down, k = up, Enter opens folder",
        setup = function()
          state.initial_line = vim.api.nvim_get_current_line()
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local line = vim.api.nvim_get_current_line()
          -- Must have navigated to a different line containing "test"
          return line:find("test") ~= nil and line ~= state.initial_line
        end,
      },
      {
        id = "open_test_file",
        title = "Open Test File",
        instruction = "Open tests/test_main.py from the explorer",
        hint = "Navigate to test_main.py and press Enter",
        setup = function()
          state.initial_file = vim.api.nvim_buf_get_name(0)
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local name = vim.api.nvim_buf_get_name(0)
          -- Must have CHANGED to test_main.py
          return name:find("test_main%.py") ~= nil and not state.initial_file:find("test_main%.py")
        end,
      },
      {
        id = "close_explorer",
        title = "Close File Explorer",
        instruction = "Press `<leader>e` again to close the explorer",
        hint = "Same key toggles it closed",
        setup = function()
          state.had_explorer = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")
            if ft == "neo-tree" or ft == "NvimTree" then
              state.had_explorer = true
            end
          end
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          -- Must have HAD explorer and now NOT have it
          if not state.had_explorer then return false end
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.api.nvim_buf_get_option(buf, "filetype")
            if ft == "neo-tree" or ft == "NvimTree" then
              return false
            end
          end
          return true
        end,
      },
    },
  },

  -- MODULE 7: LSP Power Features
  {
    name = "LSP Features",
    description = "Use Language Server features for smart coding",
    tasks = {
      {
        id = "open_main_lsp",
        title = "Open main.py for LSP Practice",
        instruction = "Open app/main.py",
        hint = "<leader>ff then 'main'",
        setup = function()
          state.initial_file = vim.api.nvim_buf_get_name(0)
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local name = vim.api.nvim_buf_get_name(0)
          -- Must have CHANGED to main.py
          return name:find("main%.py") ~= nil and not state.initial_file:find("main%.py")
        end,
      },
      {
        id = "signature_help",
        title = "View Function Signature",
        instruction = "Go to a `db.insert()` call, position cursor inside the parens, press `gK` or `K` for signature help",
        hint = "Navigate to db.insert(...), cursor between (), then K",
        setup = function()
          state.initial_float_count = 0
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if win ~= state.popup_win then
              local config = vim.api.nvim_win_get_config(win)
              if config.relative ~= "" then
                state.initial_float_count = state.initial_float_count + 1
              end
            end
          end
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local current_float_count = 0
          local has_signature_window = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if win ~= state.popup_win then
              local config = vim.api.nvim_win_get_config(win)
              if config.relative ~= "" then
                current_float_count = current_float_count + 1
                -- Check for signature/hover content
                local buf = vim.api.nvim_win_get_buf(win)
                local ft = vim.api.nvim_buf_get_option(buf, "filetype")
                local lines = vim.api.nvim_buf_get_lines(buf, 0, 5, false)
                local content = table.concat(lines, " ")
                if ft == "markdown" or ft == "help" or content:find("def ") or content:find("%(") or content:find("Args:") then
                  has_signature_window = true
                end
              end
            end
          end
          return current_float_count > state.initial_float_count and has_signature_window
        end,
      },
      {
        id = "code_action",
        title = "View Code Actions",
        instruction = "Press `<leader>ca` to see available code actions at cursor position",
        hint = "Space+c+a shows LSP code actions (organize imports, extract, etc.)",
        setup = function()
          state.initial_float_count = 0
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if win ~= state.popup_win then
              local config = vim.api.nvim_win_get_config(win)
              if config.relative ~= "" then
                state.initial_float_count = state.initial_float_count + 1
              end
            end
          end
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local current_float_count = 0
          local has_menu_window = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if win ~= state.popup_win then
              local config = vim.api.nvim_win_get_config(win)
              if config.relative ~= "" then
                current_float_count = current_float_count + 1
                -- Code action menus have selectable items
                local buf = vim.api.nvim_win_get_buf(win)
                local ft = vim.api.nvim_buf_get_option(buf, "filetype")
                -- Code action windows are typically menus
                if ft == "" or ft == "TelescopePrompt" or ft == "noice" then
                  has_menu_window = true
                end
              end
            end
          end
          return current_float_count > state.initial_float_count and has_menu_window
        end,
      },
      {
        id = "diagnostics_nav",
        title = "Navigate to Next Error/Warning",
        instruction = "Press `]d` to jump to the next diagnostic (error/warning)",
        hint = "]d = next diagnostic, [d = previous",
        setup = function()
          state.initial_line = vim.api.nvim_win_get_cursor(0)[1]
          state.initial_col = vim.api.nvim_win_get_cursor(0)[2]
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local line = vim.api.nvim_win_get_cursor(0)[1]
          local col = vim.api.nvim_win_get_cursor(0)[2]
          -- Must have MOVED (diagnostic navigation changes position)
          return line ~= state.initial_line or col ~= state.initial_col
        end,
      },
      {
        id = "format_file",
        title = "Format the File",
        instruction = "Press `<leader>cf` to format the current file",
        hint = "Space+c+f runs the formatter",
        setup = function()
          state.initial_buffer_content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          state.format_triggered = false
          -- Also track TextChanged events to detect formatting
          vim.api.nvim_create_autocmd("TextChanged", {
            group = state.autocommand_group,
            buffer = 0,
            once = true,
            callback = function()
              state.format_triggered = true
            end,
          })
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          -- Formatting either changed the buffer or triggered TextChanged
          local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
          return state.format_triggered or content ~= state.initial_buffer_content
        end,
      },
    },
  },

  -- MODULE 8: Terminal & Running Code
  {
    name = "Terminal & Execution",
    description = "Run your code and tests from within Neovim",
    tasks = {
      {
        id = "open_terminal",
        title = "Open Integrated Terminal",
        instruction = "Press `<C-/>` (Ctrl+/) or `<leader>ft` to open the terminal",
        hint = "Ctrl and / together opens floating terminal",
        setup = function()
          state.had_terminal = false
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
              state.had_terminal = true
            end
          end
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          if state.had_terminal then return false end
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
              return true
            end
          end
          return false
        end,
      },
      {
        id = "terminal_normal",
        title = "Exit Terminal Mode",
        instruction = "Press `<Esc><Esc>` (Escape twice) to exit terminal insert mode",
        hint = "Double Escape returns to normal mode in terminal",
        setup = function()
          state.initial_mode = vim.api.nvim_get_mode().mode
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          local mode = vim.api.nvim_get_mode().mode
          -- Must have been in terminal mode and now in normal mode
          local was_terminal = state.initial_mode == "t" or state.initial_mode == "nt"
          local is_normal = mode == "n" or mode == "nt"
          -- If started in terminal mode, require switch to normal
          if was_terminal then
            return is_normal and mode ~= state.initial_mode
          end
          -- If already in normal, any mode change counts
          return mode ~= state.initial_mode
        end,
      },
      {
        id = "close_terminal",
        title = "Close the Terminal",
        instruction = "Press `<C-/>` again to toggle the terminal closed",
        hint = "Same keybind toggles it",
        setup = function()
          state.had_visible_terminal = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
              state.had_visible_terminal = true
            end
          end
          state.task_ready = true
        end,
        detect = function()
          if not state.task_ready then return false end
          -- Must have HAD visible terminal and now NOT have it
          if not state.had_visible_terminal then return false end
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
              return false
            end
          end
          return true
        end,
      },
    },
  },
}

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

local function get_projects_base()
  return vim.fn.stdpath("data") .. "/lazyvim-belcaries-projects"
end

local function create_project(project_type)
  local template = templates[project_type]
  if not template then
    vim.notify("Unknown project type: " .. project_type, vim.log.levels.ERROR)
    return nil
  end

  local base_path = get_projects_base()
  local project_path = base_path .. "/" .. project_type .. "-practice"

  -- Create project structure
  vim.fn.mkdir(project_path .. "/app", "p")
  vim.fn.mkdir(project_path .. "/tests", "p")

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

local function get_current_task()
  local module = practice_modules[state.current_module]
  if not module then return nil end
  return module.tasks[state.current_task]
end

local function count_total_tasks()
  local total = 0
  for _, module in ipairs(practice_modules) do
    total = total + #module.tasks
  end
  return total
end

local function get_global_task_number()
  local num = 0
  for i = 1, state.current_module - 1 do
    num = num + #practice_modules[i].tasks
  end
  return num + state.current_task
end

-- ============================================================================
-- INSTRUCTION POPUP
-- ============================================================================

local function show_instruction()
  if state.popup_win and vim.api.nvim_win_is_valid(state.popup_win) then
    vim.api.nvim_win_close(state.popup_win, true)
  end

  -- Reset task state before showing new task
  state.task_ready = false
  state.transitioning = false
  state.completion_pending = false
  state.initial_line = nil
  state.initial_file = nil
  state.initial_buffer_content = nil
  state.initial_float_count = nil
  state.initial_search = nil
  state.had_telescope = nil
  state.undo_count = nil
  state.initial_reg = nil
  state.initial_hlsearch = nil
  state.initial_task_id_count = nil
  state.initial_win_count = nil
  state.initial_files = nil
  state.initial_win = nil
  state.initial_buf = nil
  state.had_explorer = nil
  state.initial_col = nil
  state.format_triggered = nil
  state.had_terminal = nil
  state.initial_mode = nil
  state.had_visible_terminal = nil

  local task = get_current_task()
  if not task then return end

  local module = practice_modules[state.current_module]
  local global_num = get_global_task_number()
  local total = count_total_tasks()

  -- Build instruction text, handling line wrapping
  local instruction_lines = {}
  local instr = task.instruction
  local max_width = 52
  while #instr > 0 do
    if #instr <= max_width then
      table.insert(instruction_lines, instr)
      break
    end
    local break_point = instr:sub(1, max_width):match(".*() ")
    if break_point then
      table.insert(instruction_lines, instr:sub(1, break_point - 1))
      instr = instr:sub(break_point + 1)
    else
      table.insert(instruction_lines, instr:sub(1, max_width))
      instr = instr:sub(max_width + 1)
    end
  end

  local lines = {
    "",
    string.format("  MODULE %d/%d: %s", state.current_module, #practice_modules, module.name),
    "  " .. string.rep("─", 54),
    "",
    string.format("  TASK %d/%d: %s", global_num, total, task.title),
    "",
  }

  -- Add instruction box
  table.insert(lines, "  ┌" .. string.rep("─", 54) .. "┐")
  for _, l in ipairs(instruction_lines) do
    table.insert(lines, "  │ " .. string.format("%-52s", l) .. " │")
  end
  table.insert(lines, "  └" .. string.rep("─", 54) .. "┘")

  table.insert(lines, "")
  table.insert(lines, "  HINT: " .. task.hint)
  table.insert(lines, "")
  table.insert(lines, "  " .. string.rep("─", 54))
  table.insert(lines, "  <leader>ps = skip | <leader>pn = next module | <leader>pq = quit")
  table.insert(lines, "")

  -- Progress bar
  local progress = math.floor((global_num / total) * 40)
  local bar = string.rep("█", progress) .. string.rep("░", 40 - progress)
  table.insert(lines, "  [" .. bar .. "] " .. math.floor(global_num / total * 100) .. "%")
  table.insert(lines, "")
  table.insert(lines, "  >> Complete the action to advance! <<")
  table.insert(lines, "")

  local width = 62
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
    title = " Developer Workflow Practice ",
    title_pos = "center",
    focusable = false,
  }

  state.popup_win = vim.api.nvim_open_win(buf, false, win_opts)
  state.popup_buf = buf

  -- Run task setup if exists
  if task.setup then
    task.setup()
  end
end

-- ============================================================================
-- TASK NAVIGATION
-- ============================================================================

local function next_task()
  -- IMMEDIATELY disable detection to prevent race conditions
  state.task_ready = false
  state.transitioning = true

  local task = get_current_task()
  if task then
    state.completed_tasks[task.id] = true
    state.total_completed = state.total_completed + 1
    vim.notify("✓ " .. task.title, vim.log.levels.INFO)
  end

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
    vim.notify("📂 Starting: " .. new_module.name, vim.log.levels.INFO)
  end

  vim.defer_fn(function()
    state.transitioning = false
    show_instruction()
  end, 200)
end

local function prev_module()
  state.current_module = math.max(1, state.current_module - 1)
  state.current_task = 1
  show_instruction()
end

local function next_module()
  state.current_module = math.min(#practice_modules, state.current_module + 1)
  state.current_task = 1
  show_instruction()
end

-- ============================================================================
-- DETECTION SYSTEM
-- ============================================================================

local function restart_task()
  -- Reset task state for retry
  state.task_ready = false
  state.completion_pending = false

  vim.notify("✗ Wrong action! Try again.", vim.log.levels.WARN)

  -- Re-run setup after a brief delay
  vim.defer_fn(function()
    local task = get_current_task()
    if task and task.setup then
      task.setup()
    end
  end, 300)
end

local function check_task_completion()
  if not state.active then return end
  if state.transitioning then return end  -- Block during task transitions
  if not state.task_ready then return end  -- Block until setup() has run
  if state.completion_pending then return end  -- Block if already completing

  local task = get_current_task()
  if not task then return end

  -- ONLY check for success - the SPECIFIC action this task requires
  -- Preparatory actions (moving cursor, positioning) are ignored
  -- User keeps trying until they do the exact right thing
  if task.detect and task.detect() then
    -- IMMEDIATELY block further completions before defer
    state.completion_pending = true
    state.task_ready = false
    vim.defer_fn(next_task, 150)
  end
end

local function setup_autocommands()
  state.autocommand_group = vim.api.nvim_create_augroup("BelcariesPractice", { clear = true })

  local events = {
    "BufEnter", "WinEnter", "CursorMoved", "CursorMovedI",
    "TextChanged", "TextChangedI", "BufWinEnter",
    "TermOpen", "TermClose", "ModeChanged", "CmdlineLeave",
  }

  for _, event in ipairs(events) do
    vim.api.nvim_create_autocmd(event, {
      group = state.autocommand_group,
      callback = function()
        vim.defer_fn(check_task_completion, 100)
      end,
    })
  end

  -- Practice keymaps
  vim.keymap.set("n", "<leader>ps", function()
    if state.active then M.skip_task() end
  end, { desc = "Skip practice task" })

  vim.keymap.set("n", "<leader>pn", function()
    if state.active then next_module() end
  end, { desc = "Next practice module" })

  vim.keymap.set("n", "<leader>pp", function()
    if state.active then prev_module() end
  end, { desc = "Previous practice module" })

  vim.keymap.set("n", "<leader>pq", function()
    if state.active then M.stop() end
  end, { desc = "Quit practice" })

  vim.keymap.set("n", "<leader>pb", function()
    if state.active then M.bookmark() end
  end, { desc = "Bookmark progress" })
end

local function clear_autocommands()
  if state.autocommand_group then
    vim.api.nvim_del_augroup_by_id(state.autocommand_group)
    state.autocommand_group = nil
  end
  -- Clean up keymaps
  pcall(vim.keymap.del, "n", "<leader>ps")
  pcall(vim.keymap.del, "n", "<leader>pn")
  pcall(vim.keymap.del, "n", "<leader>pp")
  pcall(vim.keymap.del, "n", "<leader>pq")
  pcall(vim.keymap.del, "n", "<leader>pb")
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

function M.start(project_type, from_bookmark)
  project_type = project_type or "python"

  local project_path = create_project(project_type)
  if not project_path then return end

  -- ALWAYS reset to fresh state
  state.active = true
  state.project_type = project_type
  state.project_path = project_path
  state.current_module = 1
  state.current_task = 1
  state.completed_tasks = {}
  state.total_completed = 0

  -- Only load bookmark if explicitly requested
  if from_bookmark then
    local bookmark = load_bookmark()
    if bookmark then
      state.current_module = bookmark.current_module or 1
      state.current_task = bookmark.current_task or 1
      state.total_completed = bookmark.total_completed or 0
      vim.notify("📌 Resumed from bookmark: Module " .. state.current_module .. ", Task " .. state.current_task, vim.log.levels.INFO)
    end
  end

  vim.cmd("cd " .. project_path)
  vim.cmd("edit " .. project_path .. "/README.md")

  setup_autocommands()
  show_instruction()

  if not from_bookmark then
    vim.notify(
      string.format("🚀 Practice Started: %s\n\n%d modules, %d tasks\nComplete each action to advance!",
        templates[project_type].name, #practice_modules, count_total_tasks()),
      vim.log.levels.INFO
    )
  end
end

function M.resume()
  local bookmark = load_bookmark()
  if bookmark then
    M.start(bookmark.project_type or "python", true)
  else
    vim.notify("No bookmark found. Starting fresh.", vim.log.levels.INFO)
    M.start("python", false)
  end
end

function M.skip_task()
  if not state.active then return end
  local task = get_current_task()
  vim.notify("⏭ Skipped: " .. task.title, vim.log.levels.WARN)
  next_task()
end

function M.complete_practice()
  state.active = false
  clear_autocommands()
  clear_bookmark()  -- Clear bookmark on completion

  if state.popup_win and vim.api.nvim_win_is_valid(state.popup_win) then
    vim.api.nvim_win_close(state.popup_win, true)
  end

  local total = count_total_tasks()
  local pct = math.floor(state.total_completed / total * 100)

  local lines = {
    "",
    "  🎉 PRACTICE COMPLETE!",
    "  " .. string.rep("═", 45),
    "",
    string.format("  Tasks Completed: %d / %d (%d%%)", state.total_completed, total, pct),
    "",
    "  Workflows Practiced:",
    "  ────────────────────",
    "  ✓ Code Navigation (gd, gr, K, Ctrl+o)",
    "  ✓ Surgical Editing (dd, ciw, ci\", dap)",
    "  ✓ Refactoring (yank, paste between files)",
    "  ✓ Search & Replace (/, *, :%s, live grep)",
    "  ✓ Multi-file Work (splits, buffers)",
    "  ✓ Project Navigation (file explorer)",
    "  ✓ LSP Features (hover, actions, format)",
    "  ✓ Terminal Integration",
    "",
    "  These are real developer workflows!",
    "  Practice daily to build muscle memory.",
    "",
    "  <leader>hp to practice again",
    "  <leader>ht for the full tutorial",
    "",
  }

  local width = 52
  local height = #lines
  local ui = vim.api.nvim_list_uis()[1]
  local col = math.floor((ui.width - width) / 2)
  local row = math.floor((ui.height - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

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

  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
  vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
end

function M.stop()
  state.active = false
  clear_autocommands()

  if state.popup_win and vim.api.nvim_win_is_valid(state.popup_win) then
    vim.api.nvim_win_close(state.popup_win, true)
  end

  vim.notify("Practice stopped", vim.log.levels.INFO)
end

function M.select_project()
  local total_tasks = count_total_tasks()

  local lines = {
    "",
    "  DEVELOPER WORKFLOW PRACTICE",
    "  " .. string.rep("═", 40),
    "",
    "  Action-based learning - tasks complete",
    "  only when you perform the action!",
    "",
    "  Project: Task Manager API (Python)",
    "",
    "  Modules:",
    "  ────────",
    "  1. Code Navigation (gd, gr, K, Ctrl+o)",
    "  2. Surgical Editing (dd, ciw, ci\", dap)",
    "  3. Refactoring (move code between files)",
    "  4. Search & Replace (/, *, :%s, grep)",
    "  5. Multi-file Work (splits, buffers)",
    "  6. Project Navigation (file explorer)",
    "  7. LSP Features (hover, actions, format)",
    "  8. Terminal Integration",
    "",
    string.format("  Total: %d modules, %d tasks", #practice_modules, total_tasks),
    "",
    "  Press 1 to start | q to cancel",
    "",
  }

  local width = 48
  local height = #lines
  local ui = vim.api.nvim_list_uis()[1]
  local col = math.floor((ui.width - width) / 2)
  local row = math.floor((ui.height - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

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

  local function close_and_start(start)
    vim.api.nvim_win_close(win, true)
    if start then M.start("python") end
  end

  vim.keymap.set("n", "1", function() close_and_start(true) end, { buffer = buf })
  vim.keymap.set("n", "<CR>", function() close_and_start(true) end, { buffer = buf })
  vim.keymap.set("n", "q", function() close_and_start(false) end, { buffer = buf })
  vim.keymap.set("n", "<Esc>", function() close_and_start(false) end, { buffer = buf })
end

function M.is_active()
  return state.active
end

function M.get_progress()
  return {
    module = state.current_module,
    task = state.current_task,
    completed = state.total_completed,
    total = count_total_tasks(),
  }
end

return M
