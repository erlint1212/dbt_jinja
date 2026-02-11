{# analyses/audit_compare_orders.sql #}

{% set old_etl_relation=ref('customer_orders_legacy') %} 
{# Matches models/legacy/customer_orders_legacy.sql #}

{% set dbt_relation=ref('fct_customer_orders_legacy') %}
{# Matches models/legacy/fct_customer_orders_legacy.sql #}

{{ 
    audit_helper.compare_relations(
        a_relation=old_etl_relation,
        b_relation=dbt_relation,
        primary_key="order_id"
    ) 
}}
