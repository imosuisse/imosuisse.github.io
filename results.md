---
layout: default
title: Results
nav: 4
---

<div class="tab-bar">
  {% for csv in site.data.Final_Round %}
  <button class="tab-link" onclick="selectYear(event, {{ csv[0] }})">{{ csv[0] }}</button>
  {% endfor %}
</div>

<script>
  function selectYear(event, year) {
    all = document.getElementsByClassName("results");
    for (i = 0; i < all.length; i++) {
      if (all[i].classList.contains(year)) {
        all[i].style.display = "block";
      } else {
        all[i].style.display = "none";
      }
    }
  }
</script>

{% for csv in site.data.Final_Round %}
<div class = "results final {{ csv[0] }}">
 <h2>Final Round {{ csv[0] }}</h2>
  <table>
    <thead>
      <tr>
        <th>Rank</th>
        <th>First Name</th>
        <th>Last Name</th>
        <th>P1</th>
        <th>P2</th>
        <th>P3</th>
        <th>P4</th>
        <th>P5</th>
        <th>P6</th>
        <th>P7</th>
        <th>P8</th>
        {% if csv[1][0].size == 15 %}
          <th>P9</th>
          <th>P10</th>
        {% endif %}
        <th>Total</th>
        <th>Award</th>
      </tr>
    </thead>
    <tbody>
    {% for row in csv[1] %}
      {% if forloop.first %}
        {% continue %}
      {% endif %}
      {% if row["Rank"] == "" %}
        {% continue %}
      {% endif %}
      {% tablerow pair in row %}
        {% if pair[1] == "G" %}
            Gold
          {% elsif pair[1] == "S" %}
            Silver
          {% elsif pair[1] == "B" %}
            Bronze
          {% else %}
            {{ pair[1] }}
          {% endif %}
      {% endtablerow %}
    {% endfor %}
    </tbody>
  </table>
</div>
{% endfor %}

{% for csv in site.data.Selection %}
<div class = "results selection {{ csv[0] }}">
 <h2>Selection {{ csv[0] }}</h2>
  <table>
    <thead>
      <tr>
        <th>Rank</th>
        <th>First Name</th>
        <th>Last Name</th>
        <th>P1</th>
        <th>P2</th>
        <th>P3</th>
        <th>P4</th>
        <th>P5</th>
        <th>P6</th>
        <th>P7</th>
        <th>P8</th>
        <th>P9</th>
        <th>P10</th>
        <th>P11</th>
        <th>P12</th>
        <th>Total</th>
        <th>Award</th>
      </tr>
    </thead>
    <tbody>
    {% for row in csv[1] %}
      {% if forloop.first %}
        {% continue %}
      {% endif %}
      {% if row["Rank"] == "" %}
        {% continue %}
      {% endif %}
      {% tablerow pair in row %}
        {% if pair[1] == "I" %}
          IMO
        {% elsif pair[1] == "M" %}
          MEMO
        {% elsif pair[1] == "L" %}
          IMO (Liechtenstein)
        {% else %}
          {{ pair[1] }}
        {% endif %}
      {% endtablerow %}
    {% endfor %}
    </tbody>
  </table>
</div>
{% endfor %}