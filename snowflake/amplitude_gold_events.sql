USE DATABASE TIL_DATA_ENGINEERING;
USE SCHEMA ep_dthree_staging;

CREATE OR REPLACE VIEW amplitude_gold_events AS
SELECT
    -- Base event fields
    e.event_id,
    e.session_id,
    e.session_event_order,
    e.events_list_id,
    e.event_time,
    e.user_properties_id,
    e.event_properties_id,

    -- Event list
    el.event_name,

    -- Event properties
    ep.page_url,
    ep.referrer,
    ep.page_counter,
    ep.page_domain,
    ep.page_path,
    ep.page_title,
    ep.page_location,
    ep.referring_domain,
    ep.element_text,
    ep.video_url,

    -- User properties
    up.initial_utm_medium,
    up.initial_referring_domain,
    up.initial_utm_campaign,
    up.referrer AS user_referrer,
    up.initial_utm_source,
    up.initial_referrer,
    up.referring_domain AS user_referring_domain,

    -- Session
    s.user_id AS session_user_id,
    s.device_id AS session_device_id,
    s.location_id AS session_location_id,

    -- Device
    d.os_id,
    d.device_type_id,
    d.os_version,

    -- Device lookup
    dl.device_name,
    dl.device_family_id,

    -- Device family
    df.device_family,

    -- OS lookup
    o.os_name,

    -- Location
    l.ip_address,
    l.city_id,
    l.country_id,
    l.region_id,

    -- City, Region, Country
    c.city_name,
    r.region_name,
    y.country_name

FROM amplitude_silver_events e 
LEFT JOIN amplitude_silver_events_list el ON e.events_list_id = el.events_list_id

LEFT JOIN amplitude_silver_events_properties ep ON e.event_properties_id = ep.event_properties_id

LEFT JOIN amplitude_silver_user_properties up ON e.user_properties_id = up.up_id

LEFT JOIN amplitude_silver_sessions s ON e.session_id = s.session_id

LEFT JOIN amplitude_silver_device d ON s.device_id = d.device_id 

LEFT JOIN amplitude_silver_device_lookup dl ON d.device_type_id = dl.device_id 

LEFT JOIN amplitude_silver_device_family_lookup df ON dl.device_family_id = df.device_family_id

LEFT JOIN amplitude_silver_os_lookup o ON d.os_id = o.os_id

LEFT JOIN amplitude_silver_location l ON s.location_id = l.location_id

LEFT JOIN amplitude_silver_city c ON l.city_id = c.city_id

LEFT JOIN amplitude_silver_region r ON l.region_id = r.region_id

LEFT JOIN amplitude_silver_country y ON l.country_id = y.country_id;
