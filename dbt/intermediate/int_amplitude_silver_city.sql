WITH city AS (
    SELECT * FROM {{ ref('stg_ep_dthree_staging__amplitude_events') }}
)

select distinct
city as city_name,
hash(city) as city_id
from city
