{{
    config(
        materialized='table'
    )
}}

with trips_data as (
    select * 
    from {{ ref('fhv_trips') }}
),

duration_trips_data as (
    select 
        EXTRACT(YEAR FROM pickup_datetime) as trip_year,
        EXTRACT(MONTH FROM pickup_datetime) as trip_month,
        PULocationID,
        DOLocationID,
        pickup_datetime,
        dropoff_datetime,
        pickup_zone,
        dropoff_zone,
        TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) as trip_duration
    from trips_data
)

select 
    trip_year,
    trip_month,
    PULocationID,
    DOLocationID,
    pickup_datetime,
    dropoff_datetime,
    pickup_zone,
    dropoff_zone,
    trip_duration,
    PERCENTILE_CONT(trip_duration, 0.9 ) OVER (PARTITION BY trip_year, trip_month, PULocationID, DOLocationID) AS p90
from duration_trips_data
