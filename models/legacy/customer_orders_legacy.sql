WITH paid_orders as (select Orders.ID as order_id,
        Orders.CUSTOMER    as customer_id,
        Orders.ORDERED_AT AS order_placed_at,
            'completed' as order_status,
        p.total_amount_paid,
        p.payment_finalized_date,
        SPLIT_PART(C.NAME, ' ', 1) as customer_first_name,
        SPLIT_PART(C.NAME, ' ', 2) as customer_last_name
    FROM raw.jaffle_shop.orders as Orders
    left join (select ORDERID as order_id, max(CREATED) as payment_finalized_date, sum(AMOUNT) / 100.0 as total_amount_paid
from raw.stripe.payment
where STATUS <> 'fail'
group by 1) p ON orders.ID = p.order_id
left join raw.jaffle_shop.customers C on orders.CUSTOMER = C.ID ),

customer_orders as (
      select C.ID as customer_id
        , min(ORDERED_AT) as first_order_date      -- Fixed: Changed ORDER_AT to ORDERED_AT
        , max(ORDERED_AT) as most_recent_order_date -- Fixed: Changed ORDER_AT to ORDERED_AT
        , count(ORDERS.ID) AS number_of_orders
      from raw.jaffle_shop.customers C 
      left join raw.jaffle_shop.orders as Orders
      on orders.CUSTOMER = C.ID 
      group by 1)

select
    p.*,
    ROW_NUMBER() OVER (ORDER BY p.order_id) as transaction_seq,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY p.order_id) as customer_sales_seq,
    CASE WHEN c.first_order_date = p.order_placed_at
    THEN 'new'
    ELSE 'return' END as nvsr,
    x.clv_bad as customer_lifetime_value,
    c.first_order_date as fdos
    FROM paid_orders p
    left join customer_orders as c USING (customer_id)
    LEFT OUTER JOIN 
    (
            select
            p.order_id,
            sum(t2.total_amount_paid) as clv_bad
        from paid_orders p
        left join paid_orders t2 on p.customer_id = t2.customer_id and p.order_id >= t2.order_id
        group by 1
        order by p.order_id
    ) x on x.order_id = p.order_id
    ORDER BY order_id
