/**
 * Local Storage Problem Actions
 * Manages user interactions with problems (likes, lists, solved) using browser localStorage
 */

const STORAGE_KEYS = {
  like: 'problem-like',
  list: 'problem-list',
  solve: 'problem-solve'
};

// Get all problem IDs for a given action type
function getProblems(actionType) {
  const data = localStorage.getItem(STORAGE_KEYS[actionType]);
  return data ? JSON.parse(data) : [];
}

// Set problems for a given action type
function setProblems(actionType, problemIds) {
  localStorage.setItem(STORAGE_KEYS[actionType], JSON.stringify(problemIds));
}

// Check if a problem has an action
function hasAction(problemId, actionType) {
  const problems = getProblems(actionType);
  return problems.includes(problemId);
}

// Toggle an action for a problem
function toggleAction(problemId, actionType) {
  const problems = getProblems(actionType);
  const index = problems.indexOf(problemId);
  
  if (index > -1) {
    problems.splice(index, 1);
  } else {
    problems.push(problemId);
  }
  
  setProblems(actionType, problems);
  return index === -1; // Return true if added, false if removed
}

// Get count for an action type
function getActionCount(actionType) {
  return getProblems(actionType).length;
}

// Initialize action buttons on page
function initializeActionButtons() {
  document.querySelectorAll('.problem-action-btn').forEach(button => {
    const problemId = button.dataset.problemId;
    const actionType = button.dataset.actionType;
    
    if (!problemId || !actionType) return;
    
    // Set initial state
    updateButtonState(button, hasAction(problemId, actionType));
    
    // Add click handler
    button.addEventListener('click', async (e) => {
      e.preventDefault();
      const isActive = toggleAction(problemId, actionType);
      updateButtonState(button, isActive);
      updateActionCount(actionType);
    });
  });
  
  // Update all counts
  updateActionCount('like');
  updateActionCount('list');
  updateActionCount('solve');
}

// Update button visual state
function updateButtonState(button, isActive) {
  if (isActive) {
    button.classList.add('active');
  } else {
    button.classList.remove('active');
  }
}

// Update count display (not used for now, but keep for future)
function updateActionCount(actionType) {
  const count = getActionCount(actionType);
  // Could be used to show counts in UI if needed
}

// Re-initialize buttons in a container (for dynamically loaded content)
function reinitializeButtons(container = document) {
  container.querySelectorAll('.problem-action-btn').forEach(button => {
    const problemId = button.dataset.problemId;
    const actionType = button.dataset.actionType;
    
    if (!problemId || !actionType) return;
    
    // Remove existing listeners by cloning
    const newButton = button.cloneNode(true);
    button.parentNode.replaceChild(newButton, button);
    
    // Set initial state
    updateButtonState(newButton, hasAction(problemId, actionType));
    
    // Add click handler
    newButton.addEventListener('click', async (e) => {
      e.preventDefault();
      const isActive = toggleAction(problemId, actionType);
      updateButtonState(newButton, isActive);
      updateActionCount(actionType);
    });
  });
}

// Export functions for use in other scripts
window.problemActions = {
  getProblems,
  hasAction,
  toggleAction,
  getActionCount,
  initializeActionButtons,
  reinitializeButtons
};

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeActionButtons);
} else {
  initializeActionButtons();
}
