---
title: Participants
layout: default
nav: 4
---

{% assign names = "" | split: "" %}

{% for exam in site.exams %}
    {% if exam.round == "Final Round" or exam.round == "Selection" %}
        {% for participant in exam.participants %}
            {% assign name = participant.last-name | append: " " | append: participant.first-name %}
            {% unless names contains name %}
                {% unless participant.last-name == "?" %}
                    {% assign names = names | push: name %}
                {% endunless %}
            {% endunless %}
        {% endfor %}
    {% endif %}
{% endfor %}

{% assign names = names | sort %}

<h2>Index of Participants</h2>

Listed below are all participants of the Swiss Mathematical Olympiad that have reached at least the Final Round,
sorted alphabetically by last name.

There are currently <b>{{ names | size }}</b> participants listed.

{% assign current = "" %}
<ul class = "participants">
    <div class = "no-split">
    {% for name in names %}
        {% assign letter = name | slice: 0,1 %}
        {% if letter != current %}
            </div>
            <div class = "no-split">
            {% assign current = letter %}
            <li class = "subtitle">{{ letter }}</li>
        {% endif %}
        <li>{{ name }}</li>
    {% endfor %}
    </div>
</ul>
