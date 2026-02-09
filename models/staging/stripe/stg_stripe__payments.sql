with 

source as (

    select * from {{ source('stripe', 'payment') }}

),

renamed as (

    select
        id as payment_id,
        cast(orderid as varchar) as order_id,
        paymentmethod as payment_method,
        status,

        -- amount is stored in cents, convert it to dollars
        -- amount / 100 as amount,
        {{ cents_to_dollars("amount", 4) }} as amount,
        created as created_at

    from source

)

select * from renamed
