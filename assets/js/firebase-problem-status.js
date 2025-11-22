/**
 * Firebase Problem Status Module
 * 
 * Handles problem status tracking (solved/list) using Firestore.
 * Each status is stored as a document with ID: {userId}_{problemId}
 * 
 * Dependencies: Firebase SDK v9+ (modular), firebase-auth.js
 * 
 * Usage:
 *   import { initStatus, setStatus, getStatus, removeStatus } from './firebase-problem-status.js';
 *   
 *   // Initialize with Firebase config
 *   initStatus(firebaseConfig);
 *   
 *   // Set problem status
 *   await setStatus(userId, problemId, 'solved');
 *   
 *   // Get problem status
 *   const status = await getStatus(userId, problemId); // returns 'solved', 'list', or null
 *   
 *   // Remove status
 *   await removeStatus(userId, problemId);
 */

import { initializeApp, getApp } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js';
import { 
  getFirestore, 
  doc, 
  getDoc, 
  setDoc, 
  deleteDoc
} from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js';

let db = null;

/**
 * Initialize Firestore for problem status
 * Uses existing Firebase app if already initialized
 * 
 * @param {Object} config - Firebase configuration object
 */
export function initStatus(config) {
  let app;
  try {
    // Try to get existing default app
    app = getApp();
  } catch (error) {
    // No app exists yet, create it
    app = initializeApp(config);
  }
  db = getFirestore(app);
}

/**
 * Get status of a problem for a user
 * 
 * @param {string} userId - User ID from Firebase Auth
 * @param {string} problemId - Problem ID (filename without extension)
 * @param {string} statusType - Specific status to check ('solved' or 'list')
 * @returns {Promise<boolean>} True if status is set
 */
export async function getStatus(userId, problemId, statusType) {
  if (!db) throw new Error('Firestore not initialized. Call initStatus() first.');
  if (!userId || !problemId) return false;
  
  try {
    const statusId = `${userId}_${problemId}`;
    const statusRef = doc(db, statusType, statusId);
    const statusDoc = await getDoc(statusRef);
    
    return statusDoc.exists();
  } catch (error) {
    console.error('Error getting problem status:', error);
    return false;
  }
}

/**
 * Set status for a problem
 * 
 * @param {string} userId - User ID from Firebase Auth
 * @param {string} problemId - Problem ID (filename without extension)
 * @param {string} status - Status to add ('solved' or 'list')
 * @returns {Promise<void>}
 */
export async function setStatus(userId, problemId, status) {
  if (!db) throw new Error('Firestore not initialized. Call initStatus() first.');
  if (!userId) throw new Error('User must be logged in to set status');
  if (!problemId) throw new Error('Problem ID is required');
  if (!['solved', 'list'].includes(status)) {
    throw new Error('Status must be "solved" or "list"');
  }
  
  try {
    const statusId = `${userId}_${problemId}`;
    const statusRef = doc(db, status, statusId);
    
    await setDoc(statusRef, {
      userId: userId,
      problemId: problemId,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error setting problem status:', error);
    throw error;
  }
}

/**
 * Remove status for a problem
 * 
 * @param {string} userId - User ID from Firebase Auth
 * @param {string} problemId - Problem ID (filename without extension)
 * @param {string} statusType - Status to remove ('solved' or 'list')
 * @returns {Promise<void>}
 */
export async function removeStatus(userId, problemId, statusType) {
  if (!db) throw new Error('Firestore not initialized. Call initStatus() first.');
  if (!userId) throw new Error('User must be logged in');
  if (!problemId) throw new Error('Problem ID is required');
  
  try {
    const statusId = `${userId}_${problemId}`;
    const statusRef = doc(db, statusType, statusId);
    await deleteDoc(statusRef);
  } catch (error) {
    console.error('Error removing problem status:', error);
    throw error;
  }
}
