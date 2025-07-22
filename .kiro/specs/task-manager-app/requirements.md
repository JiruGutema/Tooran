# Requirements Document

## Introduction

This document outlines the requirements for a Flutter-based task management application similar to Tooran. The application will allow users to organize tasks into categories, manage task completion, and provide an intuitive interface for task organization with data persistence.

## Requirements

### Requirement 1

**User Story:** As a user, I want to create and manage task categories, so that I can organize my tasks into logical groups.

#### Acceptance Criteria

1. WHEN the user taps the add category button THEN the system SHALL display a text input field for category name
2. WHEN the user enters a category name and confirms THEN the system SHALL create a new category and add it to the list
3. WHEN the user swipes left on a category THEN the system SHALL show an edit option
4. WHEN the user swipes right on a category THEN the system SHALL show a delete option with confirmation
5. WHEN the user deletes a category THEN the system SHALL move it to deleted categories with undo option

### Requirement 2

**User Story:** As a user, I want to add, edit, and manage tasks within categories, so that I can track my work items effectively.

#### Acceptance Criteria

1. WHEN the user taps on a category THEN the system SHALL expand to show tasks and input field
2. WHEN the user enters task name and description THEN the system SHALL create a new task in that category
3. WHEN the user taps on a task THEN the system SHALL show task details including description
4. WHEN the user swipes on a task THEN the system SHALL provide edit and delete options
5. WHEN the user taps the checkbox THEN the system SHALL toggle task completion status

### Requirement 3

**User Story:** As a user, I want to see progress indicators for each category, so that I can track completion status at a glance.

#### Acceptance Criteria

1. WHEN a category contains tasks THEN the system SHALL display a progress bar showing completion percentage
2. WHEN tasks are completed or uncompleted THEN the system SHALL update the progress bar in real-time
3. WHEN all tasks in a category are completed THEN the system SHALL show 100% progress with green color
4. WHEN no tasks are completed THEN the system SHALL show 0% progress with red color

### Requirement 4

**User Story:** As a user, I want my tasks and categories to be saved automatically, so that I don't lose my data when I close the app.

#### Acceptance Criteria

1. WHEN the user makes any changes to categories or tasks THEN the system SHALL automatically save data to local storage
2. WHEN the user reopens the app THEN the system SHALL load all previously saved categories and tasks
3. WHEN data loading fails THEN the system SHALL handle errors gracefully and start with empty state
4. WHEN the user deletes categories THEN the system SHALL save them to deleted categories for recovery

### Requirement 5

**User Story:** As a user, I want to reorder categories and tasks by dragging, so that I can organize them according to my priorities.

#### Acceptance Criteria

1. WHEN the user long-presses and drags a category THEN the system SHALL allow reordering of categories
2. WHEN the user long-presses and drags a task THEN the system SHALL allow reordering of tasks within a category
3. WHEN reordering is complete THEN the system SHALL save the new order automatically
4. WHEN reordering THEN the system SHALL provide visual feedback during the drag operation

### Requirement 6

**User Story:** As a user, I want to recover deleted categories, so that I can restore accidentally deleted items.

#### Acceptance Criteria

1. WHEN the user accesses the history page THEN the system SHALL show all deleted categories with deletion timestamps
2. WHEN the user selects restore on a deleted category THEN the system SHALL move it back to active categories
3. WHEN the user selects permanent delete THEN the system SHALL remove the category permanently
4. WHEN categories are restored THEN the system SHALL maintain all original tasks and their completion status

### Requirement 7

**User Story:** As a user, I want to switch between dark and light themes, so that I can use the app comfortably in various lighting conditions and according to my preferences.

#### Acceptance Criteria

1. WHEN the app loads THEN the system SHALL display the user's previously selected theme or default to system theme
2. WHEN the user accesses theme settings THEN the system SHALL provide options for light, dark, and system themes
3. WHEN the user changes theme THEN the system SHALL apply the new theme immediately across all screens
4. WHEN displaying categories THEN the system SHALL use expansion tiles with clear visual hierarchy in both themes
5. WHEN showing progress THEN the system SHALL use color-coded progress indicators that work in both themes
6. WHEN displaying dialogs THEN the system SHALL maintain consistent theme styling
7. WHEN the theme changes THEN the system SHALL save the preference and persist it across app sessions