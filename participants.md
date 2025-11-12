---
title: Participants
layout: default
nav: 4
---

{% assign names = "" | split: "" %}

{% for exam in site.exams %}
    {% for participant in exam.participants %}
        {% assign name = participant.last-name | append: " " | append: participant.first-name %}
        {% unless names contains name %}
            {% assign names = names | push: name %}
        {% endunless %}
    {% endfor %}
{% endfor %}

{% assign names = names | sort %}

<h2>Index of Participants</h2>

Listed below are all participants of the Swiss Mathematical Olympiad that have reached at least the Final Round,
sorted alphabetically by last name.

{% assign current = "" %}
<ul class = "participants">
  {% for name in names %}
    {% assign letter = name | slice: 0,1 | upcase %}
    {% if letter != current %}
      {% assign current = letter %}
      <li class = "subtitle">{{ letter }}</li>
    {% endif %}
    <li>{{ name }}</li>
  {% endfor %}
</ul>
