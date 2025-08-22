# MCP Chat UI Implementation Plan

This document outlines the step-by-step implementation plan for converting the static HTML designs into the Rails application.

## Overview

Converting 5 static HTML designs into 3 dynamic Rails views:
- **Designs 01-03** → `app/views/mcp_chat/show.html.erb` (different states)
- **Design 04** → `app/views/mcp_chat/new.html.erb` (welcome screen)  
- **Design 05** → `app/views/mcp_chat/toolbox.html.erb` (tools listing)

## Phase 1: Styling Setup

### 1.1 Add Custom CSS Classes
- [ ] Create `app/assets/stylesheets/mcp_chat.css` 
- [ ] Add design-specific color classes:
  - `.bg-claude-orange` (#FF6B35)
  - `.bg-claude-blue` (#0066CC) 
  - `.bg-chat-bg` (#F8FAFC)
  - `.bg-assistant-bg` (#F1F5F9)
  - `.bg-user-bg` (#EBF4FF)
  - `.bg-tool-bg` (#FEF3C7)
  - `.bg-confirm-bg` (#FFF7ED)
  - `.gradient-claude` (linear-gradient orange to blue)
- [ ] Add text color classes matching the backgrounds
- [ ] Add hover state classes

### 1.2 Verify Tailwind Integration
- [ ] Ensure all Tailwind classes from designs are available
- [ ] Test that custom classes work with Tailwind build process

## Phase 2: View Implementation

### 2.1 Update `app/views/mcp_chat/show.html.erb`
**Status: Replaces current basic view with modern chat interface**

#### Base Structure (Design 01 - Main Chat)
- [ ] Add modern header with logo and "New Chat" button
- [ ] Create chat messages container with proper scrolling
- [ ] Implement message display loop with new styling:
  - [ ] System messages (gray styling)
  - [ ] User messages (blue styling, right-aligned)  
  - [ ] Assistant messages (gray styling, left-aligned)
  - [ ] Tool execution messages (green styling)
- [ ] Add modern chat input form at bottom
- [ ] Replace inline styles with Tailwind classes

#### Tool Confirmation State (Design 02)
- [ ] Style tool confirmation card with orange warning theme
- [ ] Show tool name, description, and collapsible arguments
- [ ] Replace basic YES/NO buttons with styled Allow/Deny buttons
- [ ] Disable chat input during confirmation
- [ ] Maintain existing `@mcp_chat.pending_tool_confirmation?` logic

#### Tool Execution Display Enhancement (Design 03)  
- [ ] Add success indicators for completed tool calls
- [ ] Show execution summary with metadata
- [ ] Add collapsible execution details section
- [ ] Display both call arguments and tool response
- [ ] Show execution timing and tool ID

### 2.2 Update `app/views/mcp_chat/new.html.erb`
**Status: Replace basic form with welcome screen (Design 04)**

- [ ] Add welcome header with MCP Chat branding
- [ ] Create feature showcase grid (3 feature cards)
- [ ] Add suggested prompts section with clickable examples
- [ ] Style chat input form to match main interface
- [ ] Replace inline styles with Tailwind classes
- [ ] Maintain existing form submission to `/mcp_chat/chat`

### 2.3 Update `app/views/mcp_chat/toolbox.html.erb`  
**Status: Replace basic table with modern tools grid (Design 05)**

- [ ] Add proper header with tool count and "Back to Chat" button
- [ ] Replace table layout with responsive grid of tool cards
- [ ] For each tool card, display:
  - [ ] Tool name and category badge
  - [ ] Description
  - [ ] Required parameters list with types
  - [ ] Collapsible full JSON schema
- [ ] Add info section explaining MCP tools
- [ ] Style with Tailwind classes
- [ ] Maintain existing `@tools` data structure

## Phase 3: Controller Enhancements

### 3.1 Review Current Controller Logic
- [ ] Verify `mcp_chat_controller.rb` handles all design states correctly
- [ ] Check if any additional instance variables needed for new UI elements
- [ ] Ensure tool confirmation flow works with new styling

### 3.2 Potential Enhancements
- [ ] Add helper methods for message styling if needed
- [ ] Consider adding tool execution metadata display
- [ ] Review error handling for new UI states

## Phase 4: JavaScript & Interactivity

### 4.1 Essential JavaScript Features
- [ ] Auto-scroll chat to bottom on new messages
- [ ] Collapsible sections (tool arguments, execution details)
- [ ] Form submission handling
- [ ] Suggested prompts clickability (if implementing)

### 4.2 Enhanced Features (Optional)
- [ ] Smooth animations for state transitions
- [ ] Improved form validation feedback
- [ ] Copy-to-clipboard for tool results
- [ ] Keyboard shortcuts (Enter to send, etc.)

## Phase 5: Testing & Refinement

### 5.1 Functional Testing
- [ ] Test normal chat flow with message display
- [ ] Test tool confirmation workflow (YES/NO)
- [ ] Test tool execution results display
- [ ] Test new chat creation
- [ ] Test tools listing page
- [ ] Test navigation between all pages

### 5.2 UI/UX Testing
- [ ] Verify responsive design on different screen sizes
- [ ] Test with various message lengths and types
- [ ] Test with multiple tool calls in sequence
- [ ] Check accessibility (keyboard navigation, contrast)
- [ ] Verify PWA compatibility

### 5.3 Cross-browser Testing
- [ ] Test in Chrome (primary target)
- [ ] Test in Safari and Firefox
- [ ] Verify mobile browser compatibility

## Implementation Questions

Before starting implementation, please clarify:

1. **Layout Modifications**: Should I modify `app/views/layouts/application.html.erb` or keep the header/navigation within individual views?

2. **State Management**: The `show.html.erb` needs to handle 3 different UI states. Should I:
   - Use conditional blocks within one template?
   - Create partial templates for each state?
   - Add controller logic to determine which state to render?

3. **JavaScript Framework**: Any preference for JavaScript implementation?
   - Vanilla JS with Stimulus controllers?
   - Simple jQuery-style interactions?
   - Pure CSS solutions where possible?

4. **Tool Schema Display**: The current controller provides basic tool info. Do I need to enhance the controller to provide the full JSON schema for the collapsible details?

5. **Progressive Enhancement**: Should the new UI gracefully degrade if JavaScript is disabled, or can we assume JavaScript availability?

## Dependencies

- TailwindCSS v4 (already installed)
- Current `ruby-mcp-client` gem functionality
- Current controller logic and routes
- Current model methods (`@mcp_chat.ui_messages`, `@mcp_chat.pending_tool_confirmation?`, etc.)

## Estimated Timeline

- **Phase 1**: 2-3 hours
- **Phase 2**: 6-8 hours  
- **Phase 3**: 1-2 hours
- **Phase 4**: 2-4 hours
- **Phase 5**: 2-3 hours

**Total**: 13-20 hours depending on enhancement level and testing thoroughness.