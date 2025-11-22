/**
 * Problem Likes UI Handler
 * 
 * Initializes like buttons on the problems page and handles user interactions.
 * Requires user to be logged in to like problems.
 */

import { initAuth, onAuthChange, getCurrentUser } from '/assets/js/firebase-auth.js';
import { initLikes, toggleLike, isLiked, getLikeCount } from '/assets/js/firebase-likes.js';
import { initStatus, setStatus, getStatus, removeStatus } from '/assets/js/firebase-problem-status.js';

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

// Current user reference
let currentUser = null;

/**
 * Initialize all like buttons and status buttons on the page
 */
function initializeLikeButtons() {
  const likeButtons = document.querySelectorAll('.like-button');
  
  likeButtons.forEach(button => {
    const problemId = button.dataset.problemId;
    
    // Set initial state based on auth
    updateButtonState(button, currentUser, problemId);
    
    // Load like count
    updateLikeCount(problemId);
    
    // Add click handler
    button.addEventListener('click', async (e) => {
      e.preventDefault();
      await handleLikeClick(button, problemId);
    });
  });
  
  // Initialize status buttons
  initializeStatusButtons();
}

/**
 * Initialize all status buttons (solved/list)
 */
function initializeStatusButtons() {
  const statusButtons = document.querySelectorAll('.status-button');
  
  statusButtons.forEach(button => {
    const problemId = button.dataset.problemId;
    const statusType = button.dataset.status;
    
    // Set initial state
    updateStatusButtonState(button, currentUser, problemId);
    
    // Add click handler
    button.addEventListener('click', async (e) => {
      e.preventDefault();
      await handleStatusClick(button, problemId, statusType);
    });
  });
}

/**
 * Update button appearance based on user and like state
 */
async function updateButtonState(button, user, problemId) {
  if (!user) {
    // Not logged in - show empty heart
    button.classList.remove('liked');
    button.disabled = false;
    button.title = 'Login to like this problem';
    return;
  }
  
  // Check if user has liked this problem
  try {
    const liked = await isLiked(user.uid, problemId);
    if (liked) {
      button.classList.add('liked');
      button.title = 'Unlike this problem';
    } else {
      button.classList.remove('liked');
      button.title = 'Like this problem';
    }
    button.disabled = false;
  } catch (error) {
    console.error('Error checking like state:', error);
    button.disabled = false;
  }
}

/**
 * Update like count display for a problem
 */
async function updateLikeCount(problemId) {
  const countElement = document.querySelector(`.like-count[data-problem-id="${problemId}"]`);
  if (!countElement) return;
  
  try {
    const count = await getLikeCount(problemId);
    countElement.textContent = count;
    countElement.classList.add('loaded');
  } catch (error) {
    console.error('Error fetching like count:', error);
    countElement.textContent = '0';
    countElement.classList.add('loaded');
  }
}

/**
 * Handle like button click
 */
async function handleLikeClick(button, problemId) {
  const user = getCurrentUser();
  
  if (!user) {
    // Redirect to login
    window.location.href = '/account/';
    return;
  }
  
  // Disable button during operation
  button.disabled = true;
  
  try {
    const newState = await toggleLike(user.uid, problemId);
    
    // Update UI
    if (newState) {
      button.classList.add('liked');
      button.title = 'Unlike this problem';
    } else {
      button.classList.remove('liked');
      button.title = 'Like this problem';
    }
    
    // Update like count
    await updateLikeCount(problemId);
  } catch (error) {
    console.error('Error toggling like:', error);
    alert('Failed to toggle like. Please try again.');
  } finally {
    button.disabled = false;
  }
}

/**
 * Update status button appearance based on user and status
 */
async function updateStatusButtonState(button, user, problemId) {
  if (!user) {
    button.classList.remove('active');
    button.disabled = false;
    button.title = 'Login to mark this problem';
    return;
  }
  
  try {
    const buttonStatus = button.dataset.status;
    const hasStatus = await getStatus(user.uid, problemId, buttonStatus);
    
    if (hasStatus) {
      button.classList.add('active');
      button.title = `Remove ${buttonStatus} status`;
    } else {
      button.classList.remove('active');
      button.title = `Mark as ${buttonStatus}`;
    }
    button.disabled = false;
  } catch (error) {
    console.error('Error checking status:', error);
    button.disabled = false;
  }
}

/**
 * Handle status button click
 */
async function handleStatusClick(button, problemId, statusType) {
  const user = getCurrentUser();
  
  if (!user) {
    window.location.href = '/account/';
    return;
  }
  
  button.disabled = true;
  
  try {
    const hasStatus = await getStatus(user.uid, problemId, statusType);
    
    if (hasStatus) {
      // Remove this status
      await removeStatus(user.uid, problemId, statusType);
      button.classList.remove('active');
      button.title = `Mark as ${statusType}`;
    } else {
      // Add this status
      await setStatus(user.uid, problemId, statusType);
      button.classList.add('active');
      button.title = `Remove ${statusType} status`;
    }
  } catch (error) {
    console.error('Error toggling status:', error);
    alert('Failed to update status. Please try again.');
  } finally {
    button.disabled = false;
  }
}

/**
 * Update all buttons when auth state changes
 */
onAuthChange((user) => {
  currentUser = user;
  
  // Update like buttons
  const likeButtons = document.querySelectorAll('.like-button');
  likeButtons.forEach(button => {
    const problemId = button.dataset.problemId;
    updateButtonState(button, user, problemId);
  });
  
  // Update status buttons
  const statusButtons = document.querySelectorAll('.status-button');
  statusButtons.forEach(button => {
    const problemId = button.dataset.problemId;
    updateStatusButtonState(button, user, problemId);
  });
});

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeLikeButtons);
} else {
  initializeLikeButtons();
}
