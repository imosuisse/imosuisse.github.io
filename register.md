---
title: Participants
layout: default
nav: 4
---

{% assign participants = site.participants | sort: "order" %}

<h2>Register of Participants</h2>

Listed below are all participants of the Swiss Mathematical Olympiad that have reached at least the Final Round,
sorted alphabetically by last name.

There are currently <b>{{ participants.size }}</b> participants listed.

{% assign current = "" %}
<ul class = "participants">
    <div class = "no-split">
    {% for participant in participants %}
        {% assign letter = participant.order | slice: 0,1 %}
        {% if letter != current %}
            </div>
            <div class = "no-split">
            {% assign current = letter %}
            <li class = "subtitle">{{ letter }}</li>
        {% endif %}
        <li><a href = "{{ participant.url }}">{{ participant.last-name }} {{ participant.first-name }}</a></li>
    {% endfor %}
    </div>
</ul>
