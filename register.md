---
title: Participants
layout: default
description: Comprehensive register of all Swiss Mathematical Olympiad participants who reached the Final Round or beyond, with detailed performance statistics, awards, and competition history.
permalink: /participants/
---

{% assign participants = site.participants | sort: "order" %}

<h2>Register of Participants</h2>

<p>Listed below are all participants of the Swiss Mathematical Olympiad that have reached at least the Final Round,
sorted alphabetically by last name.
<br>
Participants representing Liechtenstein are marked with <b>LIE</b>.
<br>
There are currently <b>{{ participants.size }}</b> participants listed.
<p>


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
        <li><a href = "{{ participant.url }}">{{ participant.last-name }} {{ participant.first-name }}
            {% if participant.lie %} (LIE){% endif %}
        </a></li>
    {% endfor %}
    </div>
</ul>
