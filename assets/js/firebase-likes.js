/**
 * Firebase Likes Module
 * 
 * Handles like toggling for problems using Firestore.
 * Each like is stored as a document with ID: {userId}_{problemId}
 * 
 * Dependencies: Firebase SDK v9+ (modular), firebase-auth.js
 * 
 * Usage:
 *   import { initLikes, toggleLike, getLikeCount, isLiked } from './firebase-likes.js';
 *   
 *   // Initialize with Firebase config
 *   initLikes(firebaseConfig);
 *   
 *   // Check if user liked a problem
 *   const liked = await isLiked(userId, problemId);
 *   
 *   // Toggle like
 *   await toggleLike(userId, problemId);
 *   
 *   // Get total likes for a problem
 *   const count = await getLikeCount(problemId);
 */

import { initializeApp, getApp } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js';
import { 
  getFirestore, 
  doc, 
  getDoc, 
  setDoc, 
  deleteDoc,
  collection,
  query,
  where,
  getCountFromServer,
  getDocs
} from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js';

let db = null;

/**
 * Initialize Firestore for likes
 * Uses existing Firebase app if already initialized
 * 
 * @param {Object} config - Firebase configuration object
 */
export function initLikes(config) {
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
 * Check if a user has liked a problem
 * 
 * @param {string} userId - User ID from Firebase Auth
 * @param {string} problemId - Problem ID (filename without extension)
 * @returns {Promise<boolean>} True if liked, false otherwise
 */
export async function isLiked(userId, problemId) {
  if (!db) throw new Error('Firestore not initialized. Call initLikes() first.');
  if (!userId || !problemId) return false;
  
  try {
    const likeId = `${userId}_${problemId}`;
    const likeRef = doc(db, 'likes', likeId);
    const likeDoc = await getDoc(likeRef);
    return likeDoc.exists();
  } catch (error) {
    console.error('Error checking like status:', error);
    return false;
  }
}

/**
 * Toggle like for a problem
 * 
 * @param {string} userId - User ID from Firebase Auth
 * @param {string} problemId - Problem ID (filename without extension)
 * @returns {Promise<boolean>} New like state (true = liked, false = unliked)
 */
export async function toggleLike(userId, problemId) {
  if (!db) throw new Error('Firestore not initialized. Call initLikes() first.');
  if (!userId) throw new Error('User must be logged in to like');
  if (!problemId) throw new Error('Problem ID is required');
  
  try {
    const likeId = `${userId}_${problemId}`;
    const likeRef = doc(db, 'likes', likeId);
    const likeDoc = await getDoc(likeRef);
    
    if (likeDoc.exists()) {
      // Unlike: delete the document
      await deleteDoc(likeRef);
      return false;
    } else {
      // Like: create the document
      await setDoc(likeRef, {
        userId: userId,
        problemId: problemId,
        timestamp: new Date().toISOString()
      });
      return true;
    }
  } catch (error) {
    console.error('Error toggling like:', error);
    throw error;
  }
}

/**
 * Get total number of likes for a problem
 * 
 * @param {string} problemId - Problem ID (filename without extension)
 * @returns {Promise<number>} Number of likes
 */
export async function getLikeCount(problemId) {
  if (!db) throw new Error('Firestore not initialized. Call initLikes() first.');
  if (!problemId) return 0;
  
  try {
    const likesRef = collection(db, 'likes');
    const q = query(likesRef, where('problemId', '==', problemId));
    const snapshot = await getCountFromServer(q);
    return snapshot.data().count;
  } catch (error) {
    console.error('Error getting like count:', error);
    return 0;
  }
}

/**
 * Get all problems liked by a user
 * 
 * @param {string} userId - User ID from Firebase Auth
 * @returns {Promise<string[]>} Array of problem IDs
 */
export async function getUserLikes(userId) {
  if (!db) throw new Error('Firestore not initialized. Call initLikes() first.');
  if (!userId) return [];
  
  try {
    const likesRef = collection(db, 'likes');
    const q = query(likesRef, where('userId', '==', userId));
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => doc.data().problemId);
  } catch (error) {
    console.error('Error getting user likes:', error);
    return [];
  }
}
