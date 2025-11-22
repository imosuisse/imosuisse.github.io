/**
 * Account Page Authentication Logic
 */

import { 
  initAuth, 
  sendLoginEmail, 
  logout, 
  onAuthChange 
} from '/assets/js/firebase-auth.js';

import { initProblemList } from '/assets/js/account-problems.js';

// Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyAa1sz_LZsG6DQ_0gKbWn6h7_R9UFmDIb0",
  authDomain: "imosuisse-archive.firebaseapp.com",
  projectId: "imosuisse-archive",
  storageBucket: "imosuisse-archive.firebasestorage.app",
  messagingSenderId: "304866659960",
  appId: "1:304866659960:web:c708c2fde7e7d68fdd278d",
  measurementId: "G-87Y2JVZ72R"
};

// UI Elements
const loginSection = document.getElementById('login-section');
const userSection = document.getElementById('user-section');
const emailInput = document.getElementById('email-input');
const sendLinkBtn = document.getElementById('send-link-btn');
const logoutBtn = document.getElementById('logout-btn');
const loginMessage = document.getElementById('login-message');
const userEmail = document.getElementById('user-email');

// Initialize Firebase Auth
try {
  initAuth(firebaseConfig);
  console.log('Firebase Auth initialized successfully');
} catch (error) {
  console.error('Failed to initialize Firebase:', error);
  showMessage('Failed to initialize authentication. Check console for details.', 'error');
}

// Auth state listener
onAuthChange((user) => {
  if (user) {
    console.log('User logged in:', user.email);
    showUserSection(user);
  } else {
    console.log('User logged out');
    showLoginSection();
  }
});

// Send login link
sendLinkBtn.addEventListener('click', async () => {
  const email = emailInput.value.trim();
  
  if (!email) {
    showMessage('Please enter an email address', 'error');
    return;
  }
  
  if (!isValidEmail(email)) {
    showMessage('Please enter a valid email address', 'error');
    return;
  }
  
  sendLinkBtn.disabled = true;
  sendLinkBtn.textContent = 'Sending...';
  
  try {
    await sendLoginEmail(email);
    showMessage(`Login link sent to ${email}! Check your inbox.`, 'success');
    emailInput.value = '';
  } catch (error) {
    console.error('Error sending login link:', error);
    let message = 'Failed to send login link. ';
    
    if (error.code === 'auth/invalid-email') {
      message += 'Invalid email address.';
    } else if (error.code === 'auth/quota-exceeded') {
      message += 'Too many requests. Try again later.';
    } else {
      message += error.message;
    }
    
    showMessage(message, 'error');
  } finally {
    sendLinkBtn.disabled = false;
    sendLinkBtn.textContent = 'Send Login Link';
  }
});

// Allow Enter key to send login link
emailInput.addEventListener('keypress', (e) => {
  if (e.key === 'Enter') {
    sendLinkBtn.click();
  }
});

// Logout
logoutBtn.addEventListener('click', async () => {
  try {
    await logout();
    showMessage('Logged out successfully', 'success');
  } catch (error) {
    console.error('Error logging out:', error);
    showMessage('Failed to log out. Please try again.', 'error');
  }
});

// Show login section
function showLoginSection() {
  loginSection.classList.remove('hidden');
  userSection.classList.add('hidden');
  
  // Hide problem filter and list
  const problemFilterSection = document.getElementById('problem-filter-section');
  const problemList = document.getElementById('problem-list');
  problemFilterSection.classList.add('hidden');
  problemList.classList.add('hidden');
  
  loginMessage.innerHTML = '';
}

// Show user section
async function showUserSection(user) {
  loginSection.classList.add('hidden');
  userSection.classList.remove('hidden');
  
  // Show problem filter and list
  const problemFilterSection = document.getElementById('problem-filter-section');
  const problemList = document.getElementById('problem-list');
  problemFilterSection.classList.remove('hidden');
  problemList.classList.remove('hidden');
  
  userEmail.textContent = user.email;
  
  // Load problem list module
  try {
    initProblemList(user.uid);
  } catch (error) {
    console.error('Failed to load problem list:', error);
  }
}

// Display message
function showMessage(text, type = 'info') {
  loginMessage.innerHTML = `<div class="auth-message ${type}">${text}</div>`;
}

// Email validation
function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}
