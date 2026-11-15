SELECT
    office_id,
    city,
    phone,
    address_line_1,
    address_line_2,
    state,
    country,
    postal_code,
    territory
FROM {{ ref('stg_offices') }}