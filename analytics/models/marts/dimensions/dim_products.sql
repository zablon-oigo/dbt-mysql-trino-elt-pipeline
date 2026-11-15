SELECT
    p.product_id,
    p.product_name,
    p.product_line,
    pl.text_description AS product_line_description,
    p.product_scale,
    p.product_vendor,
    p.quantity_in_stock,
    p.buy_price,
    p.msrp
FROM {{ ref('stg_products') }} p
LEFT JOIN {{ ref('stg_productlines') }} pl
    ON p.product_line = pl.product_line