---
layout: default
---

<div class = "curriculum">
    {% for round in site.data.curriculum %}
    <h2>{{ round[0] }}</h2>
    <div class = "round">
        {% for topic in round[1] %}
            <div class = "topic">
                <h3>{{ topic[0] }}</h3>
                {% for subtopic in topic[1] %}
                    {% if subtopic.first %}
                        <h4>{{ subtopic[0] }}</h4>
                        {% for item in subtopic[1] %}
                            <p>{{ item }}</p>
                        {% endfor %}
                    {% else %}
                        <p>{{ subtopic }}</p>
                    {% endif %}
                {% endfor %}
            </div>
        {% endfor %}
    </div>
    {% endfor %}
</div>

