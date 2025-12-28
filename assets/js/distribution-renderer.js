const labelIncrement = 7;

function linkHover(source, target) {
    source.addEventListener("mouseenter", () => {
        target.classList.add("highlighted");
    });
    source.addEventListener("mouseleave", () => {
        if (!target.classList.contains("scroll-highlighted"))
            target.classList.remove("highlighted");
    });
    source.addEventListener("click", () => {
        target.scrollIntoView({
            behavior:"smooth",
            block:"center",
            inline:"nearest"
        });
        target.classList.add("scroll-highlighted");
        target.classList.add("highlighted");
        setTimeout(() => {
            target.classList.remove("highlighted");
            setTimeout(() => {target.classList.remove("scroll-highlighted");},200);
        }, 1000)
    })
}

function renderDistribution(participants, maxScore, container) {
    scoreHist = [];
    for (let i = 0; i <= maxScore; i++) {
        scoreHist.push([]);
    }

    for (p of participants) {
        scoreHist[p.total].push([p.award,p.first_name+"-"+p.last_name])
    }
    // console.log(scoreHist);

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
                    linkHover(row,square);
                    linkHover(square,row);
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

    const axisRow = document.createElement("tr");
    for (let x = 0; x <= maxScore; x++) {
        const el = document.createElement("td");
        el.classList.add("label");
        if (x % labelIncrement == 0) el.innerHTML = x;
        axisRow.appendChild(el);
    }
    
    axisRow.classList.add("label-row")
    table.appendChild(axisRow);

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