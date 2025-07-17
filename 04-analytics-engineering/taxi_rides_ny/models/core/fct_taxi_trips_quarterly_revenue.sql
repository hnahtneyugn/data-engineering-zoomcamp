{{
    config(
        materialized='table'
    )
}}

with trips_data as (
    select * from {{ ref('fact_trips') }}
),

quarterly_revenue_table as (
    select 
        service_type,
        trip_year,
        trip_quarter,
        SUM(total_amount) AS quarterly_revenue
    from trips_data
    group by service_type, trip_year, trip_quarter
),

quarterly_yoy_table as (
    select
        curr.service_type,
        curr.trip_year,
        curr.trip_quarter,
        curr.quarterly_revenue as current_revenue,
        prev.quarterly_revenue as previous_revenue,
        (curr.quarterly_revenue - prev.quarterly_revenue) / NULLIF(prev.quarterly_revenue, 0) as yoy_growth
    from quarterly_revenue_table curr
    left join quarterly_revenue_table prev
        on curr.service_type = prev.service_type
        and curr.trip_quarter = prev.trip_quarter
        and curr.trip_year = prev.trip_year + 1
)

select
    service_type,
    trip_year,
    trip_quarter,
    current_revenue,
    previous_revenue,
    yoy_growth,
    concat(cast(trip_year as string), '/Q', cast(trip_quarter as string)) as year_quarter
from quarterly_yoy_table
order by service_type, trip_year, trip_quarter
