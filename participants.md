---
title: Participants
layout: default
nav: 4
---

{% assign all_names = "" | split: "" %}

{% for exam in site.exams %}
  {% for participant in exam.participants %}
    {% assign name = participant.last-name | append: " " | append: participant.first-name %}
    {% unless all_names contains name %}
      {% assign all_names = all_names | push: name %}
    {% endunless %}
  {% endfor %}
{% endfor %}

{% assign all_names = all_names | sort %}

<h2>All Participants</h2>
<ul>
{% for name in all_names %}
  <li>{{ name }}</li>
{% endfor %}
</ul>
