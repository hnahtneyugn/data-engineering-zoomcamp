{{
    config(
        materialized='table'
    )
}}

with trips_data as (
    select * from {{ ref('fact_trips') }}
),

new_trips_data as (
    select 
        service_type, 
        EXTRACT(YEAR FROM pickup_datetime) as trip_year,
        EXTRACT(MONTH FROM pickup_datetime) as trip_month,
        fare_amount
    from trips_data
    where 
        fare_amount > 0
        and trip_distance > 0
        and payment_type_description in ('Cash', 'Credit card')
)

select distinct
    service_type, 
    trip_year,
    trip_month,
    PERCENTILE_CONT(fare_amount, 0.90) OVER (PARTITION BY service_type, trip_year, trip_month) AS fare_p90,
    PERCENTILE_CONT(fare_amount, 0.95) OVER (PARTITION BY service_type, trip_year, trip_month) AS fare_p95,
    PERCENTILE_CONT(fare_amount, 0.97) OVER (PARTITION BY service_type, trip_year, trip_month) AS fare_p97
from new_trips_data
order by service_type, trip_year, trip_month

