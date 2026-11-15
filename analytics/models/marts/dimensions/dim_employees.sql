SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.first_name || ' ' || e.last_name AS full_name,
    e.email,
    e.job_title,
    e.reports_to_employee_id,
    e.office_id,
    o.city AS office_city,
    o.country AS office_country
FROM {{ ref('stg_employees') }} e
LEFT JOIN {{ ref('stg_offices') }} o
    ON e.office_id = o.office_id