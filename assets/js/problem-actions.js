/**
 * Problem Actions UI Handler
 * 
 * Unified handler for all problem actions: solved, list, like
 * All three work identically with their own collections and counts
 */

import { initAuth, onAuthChange, getCurrentUser } from '/assets/js/firebase-auth.js';
import { initLikes, toggleLike, isLiked, getLikeCount } from '/assets/js/firebase-likes.js';
import { initStatus, setStatus, getStatus, removeStatus } from '/assets/js/firebase-problem-status.js';
import { initializeApp, getApp } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js';
import { 
  getFirestore, 
  collection,
  query,
  where,
  getCountFromServer
} from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js';

const firebaseConfig = {
  apiKey: "AIzaSyAa1sz_LZsG6DQ_0gKbWn6h7_R9UFmDIb0",
  authDomain: "imosuisse-archive.firebaseapp.com",
  projectId: "imosuisse-archive",
  storageBucket: "imosuisse-archive.firebasestorage.app",
  messagingSenderId: "304866659960",
  appId: "1:304866659960:web:c708c2fde7e7d68fdd278d",
  measurementId: "G-87Y2JVZ72R"
};

// Initialize Firebase
initAuth(firebaseConfig);
initLikes(firebaseConfig);
initStatus(firebaseConfig);

let db = null;
try {
  db = getFirestore(getApp());
} catch (e) {
  // Already initialized
}

let currentUser = null;

/**
 * Get count for any action type
 */
async function getActionCount(problemId, actionType) {
  if (!db) return 0;
  
  try {
    const collectionName = actionType === 'like' ? 'likes' : actionType;
    const actionRef = collection(db, collectionName);
    const q = query(actionRef, where('problemId', '==', problemId));
    const snapshot = await getCountFromServer(q);
    return snapshot.data().count;
  } catch (error) {
    console.error(`Error getting ${actionType} count:`, error);
    return 0;
  }
}

/**
 * Check if user has performed an action
 */
async function hasAction(userId, problemId, actionType) {
  if (!userId || !problemId) return false;
  
  if (actionType === 'like') {
    return await isLiked(userId, problemId);
  } else {
    return await getStatus(userId, problemId, actionType);
  }
}

/**
 * Toggle an action
 */
async function toggleAction(userId, problemId, actionType) {
  if (actionType === 'like') {
    return await toggleLike(userId, problemId);
  } else {
    const hasIt = await getStatus(userId, problemId, actionType);
    if (hasIt) {
      await removeStatus(userId, problemId, actionType);
      return false;
    } else {
      await setStatus(userId, problemId, actionType);
      return true;
    }
  }
}

/**
 * Initialize all action buttons
 */
function initializeActionButtons() {
  const actionButtons = document.querySelectorAll('.action-button:not([data-initialized])');
  
  actionButtons.forEach(button => {
    const problemId = button.dataset.problemId;
    const actionType = button.dataset.action;
    
    // Mark as initialized
    button.dataset.initialized = 'true';
    
    // Set initial state
    updateButtonState(button, currentUser, problemId, actionType);
    
    // Load count
    updateActionCount(problemId, actionType);
    
    // Add click handler
    button.addEventListener('click', async (e) => {
      e.preventDefault();
      await handleActionClick(button, problemId, actionType);
    });
  });
}

/**
 * Re-initialize buttons (call after dynamically loading problems)
 */
export function reinitializeActionButtons() {
  initializeActionButtons();
}

/**
 * Update button appearance
 */
async function updateButtonState(button, user, problemId, actionType) {
  if (!user) {
    button.classList.remove('active');
    button.disabled = false;
    
    return;
  }
  
  try {
    const isActive = await hasAction(user.uid, problemId, actionType);
    
    if (isActive) {
      button.classList.add('active');
      
    } else {
      button.classList.remove('active');
      
    }
    button.disabled = false;
  } catch (error) {
    console.error(`Error checking ${actionType} state:`, error);
    button.disabled = false;
  }
}

/**
 * Update action count display
 */
async function updateActionCount(problemId, actionType) {
  const countElement = document.querySelector(
    `.action-count[data-problem-id="${problemId}"][data-action="${actionType}"]`
  );
  if (!countElement) return;
  
  try {
    const count = await getActionCount(problemId, actionType);
    countElement.textContent = count;
    countElement.classList.add('loaded');
  } catch (error) {
    console.error(`Error fetching ${actionType} count:`, error);
    countElement.textContent = '0';
    countElement.classList.add('loaded');
  }
}

/**
 * Handle action button click
 */
async function handleActionClick(button, problemId, actionType) {
  const user = getCurrentUser();
  
  if (!user) {
    window.location.href = '/account/';
    return;
  }
  
  button.disabled = true;
  
  try {
    const newState = await toggleAction(user.uid, problemId, actionType);
    
    // Update UI
    if (newState) {
      button.classList.add('active');
      
    } else {
      button.classList.remove('active');
      
    }
    
    // Update count
    await updateActionCount(problemId, actionType);
  } catch (error) {
    console.error(`Error toggling ${actionType}:`, error);
    alert(`Failed to toggle ${actionType}. Please try again.`);
  } finally {
    button.disabled = false;
  }
}

/**
 * Update all buttons when auth state changes
 */
onAuthChange((user) => {
  currentUser = user;
  
  const actionButtons = document.querySelectorAll('.action-button');
  actionButtons.forEach(button => {
    const problemId = button.dataset.problemId;
    const actionType = button.dataset.action;
    updateButtonState(button, user, problemId, actionType);
  });
});

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeActionButtons);
} else {
  initializeActionButtons();
}
