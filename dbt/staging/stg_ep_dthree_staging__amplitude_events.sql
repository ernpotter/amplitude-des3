with source as (
    select * from {{ source('ep_dthree_staging', 'amplitude_events') }}
),

renamed as (

    select distinct
        "_airbyte_extracted_at" airbyte_extracted_at,
        "city" city,
        "uuid" event_id,
        "region" region,
        "country" country,
        "os_name" os_name,
        "user_id" user_id,
        "event_id" session_event_order,
        "language" language,
        "platform" platform,
        "device_id" device_id,
        "source_id" source_id,
        "_insert_id" insert_id,
        "event_time" event_time,
        "event_type" event_type,
        "ip_address" ip_address,
        "os_version" os_version,
        "session_id" session_id,
        "device_type" device_type,
        "device_brand" device_brand,
        "device_model" device_model,
        "device_family" device_family,
        "processed_time" processed_time,
        "user_properties" user_properties,
        "event_properties" event_properties

    from source

)

select * from renamed
