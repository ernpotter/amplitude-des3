
WITH events AS (
    SELECT * FROM {{ ref('stg_ep_dthree_staging__amplitude_events') }}
)

, parse_evp_json_cte as (
    select distinct
        hash(e.event_properties) as event_properties_id,
        (parse_json(e.event_properties)) as json
    from events as e
)

select distinct
    event_properties_id,
    json:"[Amplitude] Page URL"::string as page_url,
    json:"referrer"::string as referrer,-- like google
    json:"[Amplitude] Page Counter"::int as page_counter,
    json:"[Amplitude] Page Domain"::string as page_domain, --like til
    json:"[Amplitude] Page Path"::string as page_path, --like /how-we-help
    json:"[Amplitude] Page Title"::string as page_title, --the nice one
    json:"[Amplitude] Page Location"::string as page_location, --page_domain with page_path
    json:"referring_domain"::string as referring_domain, -- like google
    json:"[Amplitude] Element Text"::string as element_text, --like accept
    json:"video_url"::string as video_url, --like embed link
from parse_evp_json_cte as e
