with 

source as (

    select * from {{ source('jaffle_shop', 'orders') }}

),

renamed as (

    select
        id as order_id,
        customer as customer_id,
        ordered_at as order_date,
        'completed' as order_status

    from source

)

select * from renamed
