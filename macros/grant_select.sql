{% macro grant_select(...) %}

    {% set sql %}
        ...
    {% endset %}

    {{ log(..., info=True) }}
    {% do run_query(sql) %}
    {{ log(..., info=True) }}

{% endmacro %}
