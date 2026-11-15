SELECT
    customer_id,
    customer_name,
    contact_first_name,
    contact_last_name,
    phone,
    city,
    country,
    credit_limit,
    sales_rep_employee_id
FROM {{ ref('stg_customers') }}