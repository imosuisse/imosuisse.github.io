/**
 * Account Problems Page Logic (localStorage version)
 * Displays problems that user has liked, saved, or solved
 */

document.addEventListener('DOMContentLoaded', function() {
  const filterSelect = document.getElementById('problem-filter');
  const problemList = document.getElementById('problem-list');
  
  // Update counts in the dropdown
  function updateCounts() {
    const counts = {
      like: window.problemActions.getActionCount('like'),
      list: window.problemActions.getActionCount('list'),
      solve: window.problemActions.getActionCount('solve')
    };
    
    const currentValue = filterSelect.value;
    filterSelect.innerHTML = `
      <option value="solve">Solved (${counts.solve})</option>
      <option value="list">List (${counts.list})</option>
      <option value="like">Liked (${counts.like})</option>
    `;
    filterSelect.value = currentValue;
  }
  
  // Load and display problems for selected category
  async function loadProblems() {
    const actionType = filterSelect.value;
    const problemIds = window.problemActions.getProblems(actionType);
    
    if (problemIds.length === 0) {
      problemList.innerHTML = `<p>No problems yet. Start exploring the <a href="/problems/">problem archive</a>!</p>`;
      return;
    }
    
    problemList.innerHTML = '<p>Loading problems...</p>';
    
    try {
      await window.loadProblems(problemIds, problemList, null);
      
      // Re-initialize buttons after loading
      if (window.problemActions && window.problemActions.reinitializeButtons) {
        window.problemActions.reinitializeButtons(problemList);
      }
    } catch (error) {
      console.error('Error loading problems:', error);
      problemList.innerHTML = '<p>Error loading problems. Please try again.</p>';
    }
  }
  
  // Initialize
  updateCounts();
  loadProblems();
  
  // Reload when filter changes
  filterSelect.addEventListener('change', loadProblems);
});
