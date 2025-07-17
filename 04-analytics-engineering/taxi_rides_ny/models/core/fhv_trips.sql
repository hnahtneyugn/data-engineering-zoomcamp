{{
    config(
        materialized='table'
    )
}}

with fhv_trips as (
    select *
    from {{ ref('stg_fhv_tripdata') }}
),

dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)

select 
    fhv.tripid,
    fhv.dispatching_base_num,
    fhv.pickup_datetime,
    fhv.dropoff_datetime,
    fhv.PULocationID,
    fhv.DOLocationID,
    fhv.SR_Flag,
    fhv.Affiliated_base_number,
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone
from fhv_trips as fhv
inner join dim_zones as pickup_zone
on fhv.PULocationID = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on fhv.DOLocationID = dropoff_zone.locationid

