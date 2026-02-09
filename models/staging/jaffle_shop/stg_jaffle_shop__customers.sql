with 

source as (

    select * from {{ source('jaffle_shop', 'customers') }}

),

renamed as (

    select
        id as customer_id,
        SPLIT_PART(name, ' ', 1) as first_name,
        SPLIT_PART(name, ' ', 2) as last_name

    from source

)

select * from renamed
