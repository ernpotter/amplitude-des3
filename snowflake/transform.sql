USE DATABASE TIL_DATA_ENGINEERING;
USE SCHEMA ep_dthree_staging;



------ Device Family Lookup  ------
CREATE OR REPLACE TABLE amplitude_silver_device_family_lookup AS
SELECT DISTINCT 
HASH("device_family") device_family_id,
"device_family" device_family
FROM AMPLITUDE_EVENTS
WHERE "device_family" IS NOT NULL
;


----Device Lookup-----
CREATE OR REPLACE TABLE amplitude_silver_device_lookup AS
SELECT DISTINCT 
HASH("device_type") device_id,
COALESCE("device_type", "device_family") device_name,
HASH("device_family") device_family_id
FROM AMPLITUDE_EVENTS
WHERE "device_type" IS NOT NULL
;


----- OS Lookup -------
CREATE OR REPLACE TABLE amplitude_silver_os_lookup AS
SELECT DISTINCT
HASH("os_name") os_id,
"os_name" os_name
FROM AMPLITUDE_EVENTS
WHERE "os_name" IS NOT NULL
;

---- Device ------
CREATE OR REPLACE TABLE amplitude_silver_device AS
SELECT DISTINCT 
HASH("os_name", "device_type", "device_family", "os_version") device_id,
HASH("os_name") os_id,
HASH("device_type") device_type_id,
"os_version" os_version
FROM AMPLITUDE_EVENTS
;



----------------------------------------------------------- not mine ---------------------------------------------
---Jacob----

----- Counrty -------
CREATE OR REPLACE TABLE amplitude_silver_country AS
select distinct
"country" as country_name,
hash("country") as country_id
from amplitude_events;

---- Region ------
CREATE OR REPLACE TABLE amplitude_silver_region AS
select distinct
"region" as region_name,
hash("region") as region_id
from amplitude_events;

------ City -------
CREATE OR REPLACE TABLE amplitude_silver_city AS
select distinct
"city" as city_name,
hash("city") as city_id
from amplitude_events;

---- Location ------
CREATE OR REPLACE TABLE amplitude_silver_location AS
select distinct
hash("ip_address") as location_id,
"ip_address" as ip_address,
hash("city") as city_id,
hash("country") as country_id,
hash("region") as region_id
from amplitude_events;


---- User Properties ------
CREATE OR REPLACE TABLE amplitude_silver_user_properties AS
with json as (Select
    hash("user_properties") as up_id,
    parse_json("user_properties") as parsed_json
from amplitude_events
)

select distinct
    up_id,
    parsed_json:initial_utm_medium::STRING AS initial_utm_medium,
    parsed_json:initial_referring_domain::STRING AS initial_referring_domain,
    parsed_json:initial_utm_campaign::STRING AS initial_utm_campaign,
    parsed_json:referrer::STRING AS referrer,
    parsed_json:initial_utm_source::STRING AS initial_utm_source,
    parsed_json:initial_referrer::STRING AS initial_referrer,
    parsed_json:referring_domain::STRING AS referring_domain
from json;


---- lex----

------ Sessions ------
CREATE OR REPLACE TABLE amplitude_silver_sessions AS
SELECT DISTINCT
    "session_id" AS session_id,
    "user_id" AS user_id,
    HASH("os_name", "device_type", "device_family", "os_version") device_id,
    HASH("ip_address") AS location_id
FROM amplitude_events
;

SELECT DISTINCT *
FROM amplitude_silver_sessions;

----- alex ----


------ Events -----
CREATE OR REPLACE TABLE amplitude_silver_events AS
SELECT DISTINCT
     eve."uuid"               AS event_id
    ,eve."session_id"         AS session_id
    ,eve."event_id"           AS session_event_order
    ,evel."id"                AS events_list_id
    ,eve."event_time"         AS event_time
    ,HASH(eve."user_properties") AS user_properties_id -- for future iterations change maybe?
    ,HASH(eve."event_properties") AS event_properties_id
FROM amplitude_events eve
LEFT JOIN amplitude_events_list evel
    ON eve."event_type" = evel."name";


------ Events List -----
CREATE OR REPLACE TABLE amplitude_silver_events_list AS
select distinct
    el."id" as events_list_id,
    el."name" as event_name
from amplitude_events_list as el
;


------ Events Properties ------
CREATE OR REPLACE TABLE amplitude_silver_events_properties AS
with parse_evp_json_cte as (
    select distinct
        hash(e."event_properties") as event_properties_id,
        (parse_json(e."event_properties")) as json
    from amplitude_events as e
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
    -- json:"" as 
from parse_evp_json_cte as e
;
