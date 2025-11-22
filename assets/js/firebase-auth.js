/**
 * Firebase Authentication Module
 * 
 * This module handles user authentication using Firebase Auth.
 * Supports email link (passwordless) authentication.
 * 
 * Dependencies: Firebase SDK v9+ (modular)
 * 
 * Usage:
 *   import { initAuth, sendLoginEmail, completeLogin, logout, onAuthChange } from './firebase-auth.js';
 *   
 *   // Initialize with your Firebase config
 *   initAuth(firebaseConfig);
 *   
 *   // Listen for auth state changes
 *   onAuthChange((user) => {
 *     if (user) {
 *       console.log('User logged in:', user.email);
 *     } else {
 *       console.log('User logged out');
 *     }
 *   });
 */

import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js';
import { 
  getAuth, 
  sendSignInLinkToEmail, 
  isSignInWithEmailLink,
  signInWithEmailLink,
  signOut,
  onAuthStateChanged
} from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js';

let auth = null;

/**
 * Initialize Firebase Authentication
 * Call this once before using any other functions
 * 
 * @param {Object} config - Firebase configuration object from Firebase Console
 * @returns {Object} Firebase Auth instance
 */
export function initAuth(config) {
  const app = initializeApp(config);
  auth = getAuth(app);
  
  // Check if returning from email link on page load
  if (isSignInWithEmailLink(auth, window.location.href)) {
    handleEmailLinkReturn();
  }
  
  return auth;
}

/**
 * Send passwordless login email to user
 * 
 * @param {string} email - User's email address
 * @returns {Promise<void>}
 * @throws {Error} If email sending fails
 */
export async function sendLoginEmail(email) {
  if (!auth) throw new Error('Auth not initialized. Call initAuth() first.');
  
  const actionCodeSettings = {
    // URL to redirect back to after clicking email link
    url: window.location.href,
    handleCodeInApp: true,
  };

  try {
    await sendSignInLinkToEmail(auth, email, actionCodeSettings);
    // Save email locally to complete sign-in after redirect
    window.localStorage.setItem('emailForSignIn', email);
    return { success: true };
  } catch (error) {
    console.error('Error sending login email:', error);
    throw error;
  }
}

/**
 * Handle return from email link click
 * Called automatically by initAuth if URL contains sign-in link
 * 
 * @private
 */
async function handleEmailLinkReturn() {
  let email = window.localStorage.getItem('emailForSignIn');
  
  if (!email) {
    // User opened link on different device, ask for email
    email = window.prompt('Please provide your email for confirmation');
  }
  
  if (email) {
    try {
      await signInWithEmailLink(auth, email, window.location.href);
      window.localStorage.removeItem('emailForSignIn');
      // Clean up URL by removing query parameters
      window.history.replaceState({}, document.title, window.location.pathname);
    } catch (error) {
      console.error('Error completing sign-in:', error);
      alert('Error signing in. Please try again.');
    }
  }
}

/**
 * Sign out current user
 * 
 * @returns {Promise<void>}
 */
export async function logout() {
  if (!auth) throw new Error('Auth not initialized. Call initAuth() first.');
  
  try {
    await signOut(auth);
  } catch (error) {
    console.error('Error signing out:', error);
    throw error;
  }
}

/**
 * Listen for authentication state changes
 * 
 * @param {Function} callback - Called with user object when state changes (null if logged out)
 * @returns {Function} Unsubscribe function
 */
export function onAuthChange(callback) {
  if (!auth) throw new Error('Auth not initialized. Call initAuth() first.');
  
  return onAuthStateChanged(auth, (user) => {
    callback(user);
  });
}

/**
 * Get current user
 * 
 * @returns {Object|null} Current user object or null if not logged in
 */
export function getCurrentUser() {
  if (!auth) throw new Error('Auth not initialized. Call initAuth() first.');
  return auth.currentUser;
}
