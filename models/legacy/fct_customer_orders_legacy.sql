with 

-- 1. Import CTEs (Bring all sources to the top)
orders as (
    select * from raw.jaffle_shop.orders
),

customers as (
    select * from raw.jaffle_shop.customers
),

payments as (
    select * from raw.stripe.payment
),

-- 2. Logical CTEs
completed_payments as (
    select 
        orderid as order_id, 
        max(created) as payment_finalized_date, 
        sum(amount) / 100.0 as total_amount_paid
    from payments
    where status <> 'fail'
    group by 1
),

paid_orders as (
    select 
        orders.id as order_id,
        orders.customer as customer_id,
        orders.ordered_at as order_placed_at,
        'completed' as order_status, -- Hardcoded as per previous fix
        
        -- Join in payment info
        p.total_amount_paid,
        p.payment_finalized_date,
        
        -- Join in customer info
        c.first_name, -- Assuming you fixed the split_part in the model upstream or here
        c.last_name
    from orders
    left join completed_payments as p on orders.id = p.order_id
    left join customers as c on orders.customer = c.id 
),

final as (
    select
        p.*,
        
        -- Window Functions to replace the self-joins and group bys
        row_number() over (order by p.order_id) as transaction_seq,
        
        row_number() over (
            partition by p.customer_id 
            order by p.order_id
        ) as customer_sales_seq,

        -- Calculate nvsr (New vs Returning) using lag/window functions or existing logic
        case 
            when (
                rank() over (
                partition by p.customer_id 
                order by p.order_placed_at, p.order_id
                ) = 1
            ) then 'new'
        else 'return' end as nvsr,

        -- Customer Lifetime Value (Window Sum instead of Self Join)
        sum(p.total_amount_paid) over (
            partition by p.customer_id 
            order by p.order_placed_at
        ) as customer_lifetime_value,

        -- First Day of Sale (Window Min instead of Group By)
        first_value(p.order_placed_at) over (
            partition by p.customer_id 
            order by p.order_placed_at
        ) as fdos

    from paid_orders p
)

-- 3. Simple Select Statement
select * from final
order by order_id
