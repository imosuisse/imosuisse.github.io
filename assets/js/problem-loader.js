/**
 * Problem Loader
 * 
 * Dynamically loads problem content from Jekyll-generated pages
 * and renders them with the same structure as _includes/problem.html
 */

/**
 * Fetch problem data from its page
 * @param {string} problemId - Problem ID (e.g., "2024-4-08")
 * @returns {Promise<Object>} Problem data object
 */
async function fetchProblemData(problemId) {
  try {
    const response = await fetch(`/problems/${problemId}/`);
    if (!response.ok) {
      throw new Error(`Problem not found: ${problemId}`);
    }
    
    const html = await response.text();
    const parser = new DOMParser();
    const doc = parser.parseFromString(html, 'text/html');
    
    // Extract the <main> content which contains the problem
    const mainContent = doc.querySelector('main');
    if (!mainContent) {
      throw new Error(`Main content not found for: ${problemId}`);
    }
    
    // Create a container div to hold the extracted content
    const container = document.createElement('div');
    container.innerHTML = mainContent.innerHTML;
    
    return {
      id: problemId,
      element: container
    };
  } catch (error) {
    console.error('Error fetching problem:', error);
    throw error;
  }
}

/**
 * Load problems into a container
 * @param {string[]} problemIds - Array of problem IDs
 * @param {HTMLElement} container - Container element to render into
 * @param {Function} progressCallback - Optional callback for progress updates
 */
window.loadProblems = async function(problemIds, container, progressCallback = null) {
  // Clear container immediately
  container.innerHTML = '';
  
  // Batch size for parallel fetching
  const BATCH_SIZE = 10;
  const problems = [];
  
  // Process in batches
  for (let i = 0; i < problemIds.length; i += BATCH_SIZE) {
    const batch = problemIds.slice(i, i + BATCH_SIZE);
    
    const batchPromises = batch.map(problemId => 
      fetchProblemData(problemId).catch(error => {
        console.error(`Failed to load problem ${problemId}:`, error);
        return null;
      })
    );
    
    const batchResults = (await Promise.all(batchPromises)).filter(p => p !== null);
    
    // Append batch results immediately
    batchResults.forEach(problem => {
      container.appendChild(problem.element);
      problems.push(problem);
    });
    
    // Re-initialize action buttons for this batch
    if (window.problemActions && window.problemActions.reinitializeButtons) {
      window.problemActions.reinitializeButtons(container);
    }
    
    // Report progress
    if (progressCallback && typeof progressCallback === 'function') {
      progressCallback(Math.min(i + BATCH_SIZE, problemIds.length), problemIds.length);
    }
    
    // Set up MathJax for this batch
    setupLazyMathJax(container);
  }
  
  return problems;
}

/**
 * Initialize action buttons after dynamic load
 */
async function initializeButtons() {
  try {
    if (window.problemActions && window.problemActions.reinitializeButtons) {
      window.problemActions.reinitializeButtons();
    }
  } catch (error) {
    console.error('Failed to initialize action buttons:', error);
  }
}

/**
 * Set up lazy MathJax rendering using Intersection Observer
 * Only renders MathJax when problems become visible
 */
function setupLazyMathJax(container) {
  if (!window.MathJax || !window.MathJax.typesetPromise) return;
  
  // Find all problems in the container
  const problems = container.querySelectorAll('.problem');
  
  // Create an Intersection Observer
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const problem = entry.target;
        
        // Check if already typeset
        if (!problem.dataset.mathjaxTypeset) {
          problem.dataset.mathjaxTypeset = 'true';
          
          // Typeset MathJax for this problem
          MathJax.typesetPromise([problem]).catch(err => {
            console.error('MathJax typeset error:', err);
          });
        }
        
        // Stop observing this problem
        observer.unobserve(problem);
      }
    });
  }, {
    // Start rendering slightly before element enters viewport
    rootMargin: '200px 0px',
    threshold: 0.01
  });
  
  // Observe all problems
  problems.forEach(problem => observer.observe(problem));
}

/**
 * Preload problem data (fetch but don't render)
 * Useful for prefetching problems the user might view
 * @param {string} problemId - Problem ID
 */
window.preloadProblem = async function(problemId) {
  try {
    await fetchProblemData(problemId);
  } catch (error) {
    console.error(`Failed to preload problem ${problemId}:`, error);
  }
}

// Export loadProblems globally for use in other scripts
window.loadProblems = loadProblems;
