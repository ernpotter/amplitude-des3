USE DATABASE TIL_DATA_ENGINEERING;
USE SCHEMA ep_dthree_staging;

CREATE OR REPLACE PROCEDURE amplitude_silver_events_refresh()
RETURNS STRING
LANGUAGE SQL
AS

$$

MERGE INTO amplitude_silver_events tgt
USING (
    SELECT DISTINCT
         eve."uuid"               AS event_id,
         eve."session_id"         AS session_id,
         eve."event_id"           AS session_event_order,
         evel."id"                AS id,
         eve."event_time"         AS event_time,
         HASH(eve."user_properties") AS user_properties_id,
         HASH(eve."event_properties") AS event_properties_id
    FROM amplitude_events eve
    LEFT JOIN amplitude_events_list evel
        ON eve."event_type" = evel."name"
    WHERE eve."event_time" > (
        SELECT COALESCE(MAX(event_time), '1900-01-01') FROM amplitude_silver_events
    )
) src
ON tgt.event_id = src.event_id
WHEN NOT MATCHED THEN INSERT (
    event_id,
    session_id,
    session_event_order,
    id,
    event_time,
    user_properties_id,
    event_properties_id
) VALUES (
    src.event_id,
    src.session_id,
    src.session_event_order,
    src.id,
    src.event_time,
    src.user_properties_id,
    src.event_properties_id
);

$$;


CALL amplitude_silver_events_refresh();


---- createing task/stream part 2 (for streams)---- ----- amplitude_events is our raw events table 

CREATE OR REPLACE STREAM raw_table_stream ON TABLE EP_DTHREE_STAGING.amplitude_events;

SELECT 1 FROM raw_table_stream ;

SELECT *
FROM amplitude_events;

---- creating task--------

CREATE OR REPLACE TASK run_amplitude_silver_events_refresh
WAREHOUSE = dataschool_wh
WHEN SYSTEM$STREAM_HAS_DATA ('raw_table_stream')
AS
CALL amplitude_silver_events_refresh()
;

--- adding a new row to test---
INSERT INTO TIL_DATA_ENGINEERING.EP_DTHREE_STAGING.AMPLITUDE_EVENTS
SELECT * FROM AMPLITUDE_EVENTS
LIMIT 1;

---- creating task/stream part 2 (for streams)---- ----- amplitude_events is our raw events table 

CREATE OR REPLACE STREAM raw_table_stream ON TABLE EP_DTHREE_STAGING.amplitude_events;

SELECT 1 FROM raw_table_stream ;



-----------------------------------------------------------------------
--- Dynamic Tables with other 12 tables ----
-----------------------------------------------------------------------

---- Events list -----
DROP TABLE IF EXISTS amplitude_silver_events_list;

CREATE OR REPLACE DYNAMIC TABLE amplitude_silver_events_list
TARGET_LAG = DOWNSTREAM
WAREHOUSE = dataschool_wh
AS
SELECT DISTINCT
    el."id" AS events_list_id,
    el."name" AS event_name
FROM amplitude_events_list el;


---Event Properties -----
DROP TABLE IF EXISTS amplitude_silver_events_properties;


CREATE OR REPLACE DYNAMIC TABLE amplitude_silver_events_properties
TARGET_LAG = DOWNSTREAM
WAREHOUSE = dataschool_wh
AS
with parse_evp_json_cte as (
    select distinct
        hash(e."event_properties") as event_properties_id,
        (parse_json(e."event_properties")) as json
    from amplitude_events as e
)

select
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
