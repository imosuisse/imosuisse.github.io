(function() {
    function initSortableTables() {
        document.querySelectorAll('table.sortable').forEach(table => {
            const tbody = table.querySelector('tbody') || table;
            const allHeaders = table.querySelectorAll('th');
            
            // Build column mapping for sortable headers
            const sortableHeaders = Array.from(allHeaders).map((header, headerIndex) => {
                const hasSortClass = Array.from(header.classList).some(cls => 
                    /^sort-\d+$/.test(cls) || cls === 'sort-asc' || cls === 'sort-desc'
                );
                if (!hasSortClass) return null;
                
                // Calculate which column index this header corresponds to
                const headerRow = header.parentElement;
                const headerRows = Array.from(table.querySelectorAll('tr')).filter(row => row.querySelector('th'));
                const rowIndex = headerRows.indexOf(headerRow);
                
                // Count columns from previous rows that span into this row
                let columnIndex = 0;
                for (let i = 0; i < rowIndex; i++) {
                    const prevRow = headerRows[i];
                    for (let cell of prevRow.children) {
                        const rowspan = parseInt(cell.getAttribute('rowspan') || '1');
                        const colspan = parseInt(cell.getAttribute('colspan') || '1');
                        if (rowspan > rowIndex - i) {
                            columnIndex += colspan;
                        }
                    }
                }
                
                // Count columns before this header in the same row
                for (let i = 0; i < Array.from(headerRow.children).indexOf(header); i++) {
                    const cell = headerRow.children[i];
                    columnIndex += parseInt(cell.getAttribute('colspan') || '1');
                }
                
                const colspan = parseInt(header.getAttribute('colspan') || '1');
                const columnIndices = Array.from({ length: colspan }, (_, i) => columnIndex + i);
                
                // If this has colspan, find sub-headers with priorities
                let subHeaderPriorities = null;
                if (colspan > 1 && rowIndex + 1 < headerRows.length) {
                    const nextRow = headerRows[rowIndex + 1];
                    subHeaderPriorities = [];
                    
                    // Process each cell in the next row and calculate its column index
                    for (let nextCell of nextRow.children) {
                        // Calculate column index for this next row cell
                        let nextCellColIndex = 0;
                        
                        // Count columns from previous rows that span into next row
                        for (let i = 0; i <= rowIndex; i++) {
                            const prevRow = headerRows[i];
                            for (let cell of prevRow.children) {
                                const cellRowspan = parseInt(cell.getAttribute('rowspan') || '1');
                                const cellColspan = parseInt(cell.getAttribute('colspan') || '1');
                                
                                if (i + cellRowspan > rowIndex + 1) {
                                    nextCellColIndex += cellColspan;
                                }
                            }
                        }
                        
                        // Count columns before this cell in next row
                        for (let j = 0; j < Array.from(nextRow.children).indexOf(nextCell); j++) {
                            const cell = nextRow.children[j];
                            nextCellColIndex += parseInt(cell.getAttribute('colspan') || '1');
                        }
                        
                        // Check if this cell is within our colspan range
                        if (nextCellColIndex >= columnIndex && nextCellColIndex < columnIndex + colspan) {
                            const priorityMatch = Array.from(nextCell.classList).find(cls => /^sort-\d+$/.test(cls));
                            if (priorityMatch) {
                                const priority = parseInt(priorityMatch.replace('sort-', ''));
                                subHeaderPriorities.push({ priority, columnIndex: nextCellColIndex });
                            }
                        }
                    }
                    
                    // Sort by priority and filter out if empty
                    if (subHeaderPriorities.length > 0) {
                        subHeaderPriorities.sort((a, b) => a.priority - b.priority);
                    } else {
                        subHeaderPriorities = null;
                    }
                }
                
                return { header, columnIndex, columnIndices, headerIndex, subHeaderPriorities };
            }).filter(item => item !== null);
            
            function sortTable(columnIndices, direction) {
                const rows = Array.from(tbody.querySelectorAll('tr')).filter(row => row.querySelector('td'));
                
                rows.sort((a, b) => {
                    // Sort by multiple columns in order
                    for (let columnIndex of columnIndices) {
                        let aVal = a.children[columnIndex].textContent.trim();
                        let bVal = b.children[columnIndex].textContent.trim();
                        
                        const aNum = parseFloat(aVal);
                        const bNum = parseFloat(bVal);
                        const aIsNum = !isNaN(aNum);
                        const bIsNum = !isNaN(bNum);
                        
                        let comparison;
                        if (aIsNum && bIsNum) {
                            // Both are numbers
                            comparison = direction === 'desc' ? bNum - aNum : aNum - bNum;
                        } else if (aIsNum && !bIsNum) {
                            // Numbers come before non-numbers
                            comparison = -1;
                        } else if (!aIsNum && bIsNum) {
                            // Non-numbers come after numbers
                            comparison = 1;
                        } else {
                            // Both are non-numbers, sort as strings
                            comparison = direction === 'desc' 
                                ? bVal.localeCompare(aVal)
                                : aVal.localeCompare(bVal);
                        }
                        
                        if (comparison !== 0) return comparison;
                    }
                    return 0;
                });
                
                rows.forEach(row => tbody.appendChild(row));
            }
            
            // Initial sort based on priority classes
            const priorityHeaders = sortableHeaders
                .map(({ header, columnIndex, columnIndices }) => {
                    const match = Array.from(header.classList).find(cls => /^sort-\d+$/.test(cls));
                    if (match) {
                        const priority = parseInt(match.replace('sort-', ''));
                        const hasAsc = header.classList.contains('sort-asc');
                        const hasDesc = header.classList.contains('sort-desc');
                        
                        let direction = 'asc'; // default
                        if (hasDesc) {
                            direction = 'desc';
                        } else if (hasAsc) {
                            direction = 'asc';
                        }
                        
                        return { columnIndices, priority, direction };
                    }
                    return null;
                })
                .filter(item => item !== null)
                .sort((a, b) => a.priority - b.priority);
            
            if (priorityHeaders.length > 0) {
                const rows = Array.from(tbody.querySelectorAll('tr')).filter(row => row.querySelector('td'));
                
                rows.sort((a, b) => {
                    for (let { columnIndices, direction } of priorityHeaders) {
                        for (let columnIndex of columnIndices) {
                            let aVal = a.children[columnIndex].textContent.trim();
                            let bVal = b.children[columnIndex].textContent.trim();
                            
                            const aNum = parseFloat(aVal);
                            const bNum = parseFloat(bVal);
                            
                            let comparison;
                            if (!isNaN(aNum) && !isNaN(bNum)) {
                                comparison = direction === 'desc' ? bNum - aNum : aNum - bNum;
                            } else {
                                comparison = direction === 'desc' ? bVal.localeCompare(aVal) : aVal.localeCompare(bVal);
                            }
                            
                            if (comparison !== 0) return comparison;
                        }
                    }
                    return 0;
                });
                
                rows.forEach(row => tbody.appendChild(row));
                
                // Set initial sort direction on the first priority header
                if (priorityHeaders.length > 0) {
                    const firstPriority = priorityHeaders[0];
                    const firstHeader = sortableHeaders.find(sh => 
                        sh.columnIndices.some(ci => firstPriority.columnIndices.includes(ci))
                    );
                    if (firstHeader) {
                        firstHeader.header.dataset.sortDir = firstPriority.direction;
                    }
                }
            }
            
            function updateSortIndicators(activeHeader = null) {
                sortableHeaders.forEach(({ header }) => {
                    // Remove existing indicators
                    header.classList.remove('sorted-asc', 'sorted-desc', 'sorted-active');
                    const existingIndicator = header.querySelector('.sort-indicator');
                    if (existingIndicator) {
                        existingIndicator.remove();
                    }
                    
                    // Determine sort direction (default based on classes if not set)
                    let sortDir = header.dataset.sortDir;
                    if (!sortDir) {
                        const hasAsc = header.classList.contains('sort-asc');
                        const hasDesc = header.classList.contains('sort-desc');
                        
                        if (hasDesc) {
                            sortDir = 'desc';
                        } else if (hasAsc) {
                            sortDir = 'asc';
                        } else {
                            sortDir = 'asc'; // default
                        }
                    }
                    
                    // Always add indicator
                    header.classList.add(sortDir === 'asc' ? 'sorted-asc' : 'sorted-desc');
                    const indicator = document.createElement('span');
                    indicator.className = 'sort-indicator';
                    indicator.textContent = sortDir === 'asc' ? ' ▲' : ' ▼';
                    indicator.style.fontSize = '0.8em';
                    indicator.style.marginLeft = '0.3em';
                    
                    // Highlight the active (most recently clicked) header
                    if (header === activeHeader) {
                        header.classList.add('sorted-active');
                        indicator.style.color = '#0066cc';
                        indicator.style.fontWeight = 'bold';
                    } else {
                        indicator.style.color = '#999';
                    }
                    
                    header.appendChild(indicator);
                });
            }
            
            sortableHeaders.forEach(({ header, columnIndex, columnIndices, subHeaderPriorities }) => {
                header.style.cursor = 'pointer';
                header.style.userSelect = 'none';
                
                header.addEventListener('click', function() {
                    const hasAsc = header.classList.contains('sort-asc');
                    const hasDesc = header.classList.contains('sort-desc');
                    
                    // Determine initial direction (default is ascending)
                    let initialDir = 'asc';
                    if (hasDesc) {
                        initialDir = 'desc';
                    } else if (hasAsc) {
                        initialDir = 'asc';
                    }
                    
                    // Always toggle
                    const currentDir = header.dataset.sortDir;
                    let direction;
                    if (!currentDir) {
                        // First click - use initial direction
                        direction = initialDir;
                    } else {
                        // Subsequent clicks - toggle
                        direction = currentDir === 'asc' ? 'desc' : 'asc';
                    }
                    header.dataset.sortDir = direction;
                    
                    // Reset other headers
                    sortableHeaders.forEach(({ header: h }) => {
                        if (h !== header) {
                            delete h.dataset.sortDir;
                        }
                    });
                    
                    // Use sub-header priorities if available, otherwise use column indices
                    const sortColumns = subHeaderPriorities 
                        ? subHeaderPriorities.map(sh => sh.columnIndex)
                        : columnIndices;
                    
                    sortTable(sortColumns, direction);
                    updateSortIndicators(header);
                });
            });
            
            // Show initial sort indicators
            const initialActiveHeader = priorityHeaders.length > 0 
                ? sortableHeaders.find(sh => sh.columnIndices.some(ci => priorityHeaders[0].columnIndices.includes(ci)))?.header
                : null;
            updateSortIndicators(initialActiveHeader);
        });
    }
    
    // Run immediately if DOM is ready, otherwise wait
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initSortableTables);
    } else {
        initSortableTables();
    }
})();
