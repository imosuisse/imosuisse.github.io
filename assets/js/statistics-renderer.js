const labelIncrement = 7;

function newTableHeader(content) {
    const h = document.createElement("th");
    h.textContent = content;
    h.classList.add("center");
    return h;
}

function newTableCell(content) {
    const c = document.createElement("td");
    c.textContent = content;
    c.classList.add("center");
    return c;
}

function newTableCellWithValue(content,value) {
    const c = document.createElement("td");
    c.textContent = content;
    c.classList.add("value-gradient");
    if (value < 0)
        c.classList.add("negative");
    c.style.setProperty("--value",Math.abs(value));
    c.classList.add("center");
    return c;
}

function linkHover(source, targets, scrolltarget = undefined) {
    if (!scrolltarget && targets.length == 1) scrolltarget = targets[0];
    source.addEventListener("mouseenter", () => {
        for (target of targets)
            target.classList.add("highlighted");
    });
    source.addEventListener("mouseleave", () => {
        for (target of targets)
            if (!target.classList.contains("scroll-highlighted"))
                target.classList.remove("highlighted");
    });
    source.addEventListener("click", () => {
        if (scrolltarget)
            scrolltarget.scrollIntoView({
                behavior:"smooth",
                block:"center",
                inline:"nearest"
            });
        for (target of targets) {
            target.classList.add("scroll-highlighted");
            target.classList.add("highlighted");
        }
        source.classList.add("scroll-highlighted");
        source.classList.add("highlighted");
        // setTimeout(() => {
        //     target.classList.remove("highlighted");
        //     setTimeout(() => {target.classList.remove("scroll-highlighted");},200);
        // }, 1000)
    })
}

function axisRow(start, end, inc) {
    const axisRow = document.createElement("tr");
    for (let x = start; x <= end; x++) {
        const el = document.createElement("td");
        el.classList.add("label");
        if (x % inc == 0) el.innerHTML = x;
        axisRow.appendChild(el);
    }
    
    axisRow.classList.add("label-row")
    return axisRow;
}

function renderDistribution(participants, maxScore, container) {
    scoreHist = [];
    for (let i = 0; i <= maxScore; i++) {
        scoreHist.push([]);
    }

    for (p of participants) {
        scoreHist[p.total].push([p.award,p.first_name+"-"+p.last_name])
    }

    let first = maxScore;
    let last = 0;
    let height = 0;
    for (let i = 0; i <= maxScore; i++) {
        if (scoreHist[i].length > 0) {
            first = Math.min(first,i);
            last = Math.max(last,i);
        }
        height = Math.max(height,scoreHist[i].length);
        scoreHist[i].reverse();
    }
    
    let first_el, last_el;
    const table = document.createElement("table");
    for (let y = 0; y < height; y++) {
        const row = document.createElement("tr");
        for (let x = 0; x <= maxScore; x++) {
            let i = height-y-1;
            const el = document.createElement("td");
            if (i < scoreHist[x].length) {
                const square = document.createElement("div");
                if (scoreHist[x][i][0]) {
                    square.classList.add(scoreHist[x][i][0].toLowerCase());
                }

                const row = document.getElementById("results-row-" + scoreHist[x][i][1]);
                if (row) {
                    linkHover(row,[square]);
                    linkHover(square,[row]);
                }

                el.appendChild(square);
            } else {
                el.classList.add("empty");
            }
            row.appendChild(el);
            if (x == first) first_el = el;
            if (x == last)  last_el  = el;
        }
        table.appendChild(row);
    }

    table.appendChild(axisRow(0,maxScore,labelIncrement));

    table.classList.add("distribution-table");
    container.appendChild(table);

    requestAnimationFrame(() => {
        last_el.scrollIntoView({
            behavior: 'smooth',
            block: 'nearest',
            inline: 'end'
        });
    })
}

function problemPlot(problemName, examName, hist, pcount) {
    const div = document.createElement("div");

    const table = document.createElement("table");
    table.classList.add("barplot-table");

    const datarow = document.createElement("tr");
    for (let i = 0; i <= 7; i++) {
        const cell = document.createElement("td");
        const bar = document.createElement("div");
        bar.classList.add("plot-bar");
        bar.style.setProperty("--value",hist[i]/pcount);
        bar.id = "plot-" + problemName + "-" + i;
        cell.appendChild(bar);
        cell.classList.add("bar-container");
        datarow.appendChild(cell);
    }

    table.appendChild(datarow);
    table.appendChild(axisRow(0,7,1));

    div.appendChild(table)

    const label = document.createElement("div");
    label.textContent = examName + " " + problemName;
    label.classList.add("plot-label");

    div.appendChild(label);

    return div;
}

function renderProblemDistributionTable(problemNames, count, means, stdev, table) {
    for (let p in problemNames) {
        const row = document.createElement("tr");
        row.appendChild(newTableHeader(problemNames[p]));
        for (let i = 0; i <= 7; i++) {
            row.appendChild(newTableCell(count[p][i]));
            row.lastChild.classList.add("clickable");
            row.lastChild.id = "dist-table-" + problemNames[p] + "-" + i;
        }
        row.appendChild(newTableCellWithValue(means[p].toFixed(2),means[p]/7));
        row.appendChild(newTableCellWithValue(stdev[p].toFixed(2),stdev[p]/3.5));
        table.appendChild(row);
    }
    const row = document.createElement("tr");
    row.appendChild(newTableHeader("Σ"));
    row.appendChild(newTableCell("See Distribution"));
    row.lastChild.colSpan = 8;
    row.lastChild.classList.add("clickable");
    linkHover(row.lastChild,[],document.querySelector("#distribution-container"));
    row.appendChild(newTableCellWithValue(means[means.length-1].toFixed(2),means[means.length-1]/(7*problemNames.length)));
    row.appendChild(newTableCellWithValue(stdev[stdev.length-1].toFixed(2),stdev[stdev.length-1]/(3.5*problemNames.length)));
    table.appendChild(row);
}

function renderCorrelation(problemNames, corrMatrix, table) {
    const hrow = document.createElement("tr");
    hrow.appendChild(newTableHeader("ρ"));
    for (let name of problemNames) {
        hrow.appendChild(newTableHeader(name));
    }
    hrow.appendChild(newTableHeader("Σ"));

    table.appendChild(hrow);

    problemNames.push("Σ");
    for (let i in problemNames) {
        const row = document.createElement("tr");
        row.appendChild(newTableHeader(problemNames[i]));
        for (let j in problemNames) {
            if (i != j)
                row.appendChild(newTableCellWithValue(corrMatrix[i][j].toFixed(2),corrMatrix[i][j]));
            else 
                row.appendChild(newTableCellWithValue("",0));
        }
        table.appendChild(row);
    }
} 

function renderStatistics(participants, problemNames, examName, container, distTable, corrTable) {
    let participantCount = participants.length;
    let problemCount = problemNames.length;

    const means = Array(problemCount).fill(0);
    const count = [...Array(problemCount)].map(() => Array(8).fill(0));

    for (p of participants) {
        for (i in problemNames) {
            means[i] += p.scores[i];
            count[i][p.scores[i]]++;
        }
    }
    
    let tot_mean = 0;
    for (i in means) {
        means[i] /= participantCount;
        tot_mean += means[i];
    }

    const covMatrix = [...Array(problemCount+1)].map(() => Array(problemCount+1).fill(0));

    for (p of participants) {
        for (i in problemNames) {
            for (j in problemNames) {
                covMatrix[i][j] += (p.scores[i]-means[i])*(p.scores[j]-means[j]);
            }
            covMatrix[i][problemCount] += (p.scores[i]-means[i])*(p.total-tot_mean);
            covMatrix[problemCount][i] += (p.scores[i]-means[i])*(p.total-tot_mean);
        }
        covMatrix[problemCount][problemCount] += (p.total-tot_mean)*(p.total-tot_mean);
    }

    for (i in covMatrix) {
        for (j in covMatrix[i]) {
            covMatrix[i][j] /= participantCount;
        }
    }

    const stdev = Array(problemCount+1).fill(0);

    for (i in stdev)
        stdev[i] = Math.sqrt(covMatrix[i][i]);

    for (i in problemNames) {
        container.appendChild(problemPlot(problemNames[i], examName, count[i], participantCount));
    }
    
    means.push(tot_mean);
    if (distTable) renderProblemDistributionTable(problemNames,count,means,stdev,distTable);
    
    const corrMatrix = [...Array(problemCount+1)].map(() => Array(problemCount+1).fill(0));
    for (i in covMatrix) {
        for (j in covMatrix[i]) {
            corrMatrix[i][j] = covMatrix[i][j]/(stdev[i]*stdev[j]);
        }
    }

    if (corrTable) renderCorrelation(problemNames,corrMatrix,corrTable);

    for (i in problemNames) {
        for (let j = 0; j <= 7; j++) {
            targets = []
            for (p of participants) {
                if (p.scores[i] != j) continue;
                const t = document.getElementById("results-row-" + p.first_name + "-" + p.last_name);
                if (t) targets.push(t);
            }
            const bar = document.getElementById("plot-" + problemNames[i] + "-" + j);
            const tablecell = document.getElementById("dist-table-" + problemNames[i] + "-" + j);
            targets2 = [...targets];
            targets.push(tablecell);
            linkHover(bar,targets,document.querySelector(".scores"));
            targets2.push(bar);
            linkHover(tablecell,targets2,document.querySelector(".scores"));
        }
    }
}

window.addEventListener("click", () => {
    targets = document.querySelectorAll(".scroll-highlighted");
    for (let target of targets) {
        target.classList.remove("highlighted");
        target.classList.remove("scroll-highlighted");
    }
    // setTimeout(() => {for (let target of targets) target.classList.remove("scroll-highlighted");},200);
}, true)