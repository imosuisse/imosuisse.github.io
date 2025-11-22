/**
 * Account Problems List
 * 
 * Displays user's solved/list/liked problems on the account page
 */

import { getFirestore } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js';
import { collection, query, where, getDocs } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js';
import { getApp } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js';

let db = null;

/**
 * Initialize the problem list display
 */
export function initProblemList(userId) {
  try {
    db = getFirestore(getApp());
  } catch (e) {
    console.error('Failed to get Firestore instance:', e);
    return;
  }
  
  const filterSelect = document.getElementById('problem-filter');
  if (!filterSelect) return;
  
  // Load initial list
  loadUserProblems(userId, filterSelect.value);
  
  // Add change listener
  if (!filterSelect.dataset.listenerAdded) {
    filterSelect.addEventListener('change', (e) => {
      loadUserProblems(userId, e.target.value);
    });
    filterSelect.dataset.listenerAdded = 'true';
  }
}

let currentLoadOperation = 0;

/**
 * Load user's problems by action type and render them
 */
async function loadUserProblems(userId, actionType) {
  const listContent = document.getElementById('problem-list-content');
  if (!listContent) return;
  
  const operationId = ++currentLoadOperation;
  
  listContent.innerHTML = '<p style="color: #999; padding: 1rem 0;">Loading...</p>';
  
  try {
    const collectionName = actionType === 'like' ? 'likes' : actionType;
    const problemsRef = collection(db, collectionName);
    const q = query(problemsRef, where('userId', '==', userId));
    const snapshot = await getDocs(q);
    
    // Check if still the current operation
    if (operationId !== currentLoadOperation) return;
    
    if (snapshot.empty) {
      const displayName = actionType === 'list' ? 'list' : actionType;
      listContent.innerHTML = `<p style="color: #999; padding: 1rem 0;">No ${displayName} problems yet.</p>`;
      return;
    }
    
    // Get problem IDs and sort them (descending)
    const problemIds = snapshot.docs.map(doc => doc.data().problemId).sort((a, b) => b.localeCompare(a));
    
    // Load and render full problems
    await renderProblemsWithContent(problemIds, listContent, operationId);
    
  } catch (error) {
    console.error('Error loading problems:', error);
    listContent.innerHTML = '<p style="color: red; padding: 1rem 0;">Error loading problems.</p>';
  }
}

/**
 * Render problems with full content using problem-loader
 */
async function renderProblemsWithContent(problemIds, container, operationId) {
  console.log('renderProblemsWithContent called with:', problemIds);
  
  try {
    // Dynamically import the problem loader
    const { loadProblems } = await import('/assets/js/problem-loader.js');
    console.log('Problem loader imported successfully');
    
    // Load all problems with operation ID
    await loadProblems(problemIds, container, operationId);
    console.log('Problems loaded successfully');
  } catch (error) {
    console.error('Error in renderProblemsWithContent:', error);
    container.innerHTML = `<p style="color: red;">Error rendering problems: ${error.message}</p>`;
  }
}
