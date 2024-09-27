---
layout: default
title: Results
nav: 4
---

{% for csv in site.data.Final_Round reversed %}
  <h2> Final Round {{ csv[0 ]}}</h2>

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
{% endfor %}