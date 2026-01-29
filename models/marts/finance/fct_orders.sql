with orders as ( 

    select * from {{ ref('stg_jaffle_shop__orders') }}

),

payments as (

    select * from {{ ref('stg_stripe__payments') }}

),

order_payment_totals as (

    select
        order_id,
        sum(case when status = 'success' then amount end) as amount
    from payments
    group by 1

),

final as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        coalesce(order_payment_totals.amount, 0) as amount
    from orders

    left join order_payment_totals using (order_id)

)

select * from final