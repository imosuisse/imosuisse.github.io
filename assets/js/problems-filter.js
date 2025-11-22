/**
 * Problems Page Filter
 * Filters problems by topic, round, and year without loading HTML
 */

import { loadProblems } from '/assets/js/problem-loader.js';

let allProblemsData = [];
let currentlyDisplayedIds = [];

export function initProblemsFilter(problemsData) {
  allProblemsData = problemsData;
  
  const filterButton = document.getElementById('filter');
  if (filterButton) {
    filterButton.addEventListener('click', applyFilters);
  }
  
  applyFilters();
}

async function applyFilters() {
  const container = document.getElementById('problems-container');
  if (!container) return;
  
  const filters = getFilterValues();
  const filteredIds = allProblemsData
    .filter(p => matchesFilters(p, filters))
    .map(p => p.id);
  
  // Update count
  const countElement = document.getElementById('count');
  if (countElement) {
    countElement.textContent = filteredIds.length;
  }
  
  // Skip if nothing changed
  if (JSON.stringify(filteredIds) === JSON.stringify(currentlyDisplayedIds)) {
    return;
  }
  
  currentlyDisplayedIds = filteredIds;
  
  // Load filtered problems
  if (filteredIds.length === 0) {
    container.innerHTML = '<p style="color: #999; padding: 2rem 0;">No problems match your filters.</p>';
    return;
  }
  
  container.innerHTML = '<p style="color: #999; padding: 2rem 0;">Loading problems...</p>';
  await loadProblems(filteredIds, container);
}

function getFilterValues() {
  const getChecked = (id, defaultVal = true) => document.getElementById(id)?.checked ?? defaultVal;
  
  return {
    algebra: getChecked('algebra'),
    combinatorics: getChecked('combinatorics'),
    geometry: getChecked('geometry'),
    numberTheory: getChecked('number-theory'),
    firstRound: getChecked('first-round', false),
    secondRound: getChecked('second-round'),
    finalRound: getChecked('final-round'),
    selection: getChecked('selection'),
    yearFrom: parseInt(document.getElementById('from')?.value ?? 2020),
    yearTo: parseInt(document.getElementById('to')?.value ?? 2025)
  };
}

function matchesFilters(problem, filters) {
  // Year filter
  if (problem.year < filters.yearFrom || problem.year > filters.yearTo) {
    return false;
  }
  
  // Round filter
  const rounds = [filters.firstRound, filters.secondRound, filters.finalRound, filters.selection];
  if (!rounds[problem.round - 1]) {
    return false;
  }
  
  // Topic filter
  const topics = { A: filters.algebra, C: filters.combinatorics, G: filters.geometry, N: filters.numberTheory };
  if (!topics[problem.topic]) {
    return false;
  }
  
  return true;
}
