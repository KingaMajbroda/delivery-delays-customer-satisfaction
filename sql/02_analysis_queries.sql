-- SQL analysis queries for the Impact of Delivery Delays on Customer Satisfaction project.
-- This script contains the main analytical queries used to explore delivery delays,
-- review scores, and order value patterns.
--
-- The queries use cleaned and analysis-ready tables created in 01_data_preparation.sql.

-- Query 01: Overall delayed orders rate
-- Business question: What share of delivered orders were delayed?

SELECT 
    COUNT(*) AS delivered_orders,
    SUM(CASE WHEN delivery_delay_days > 0 THEN 1 ELSE 0 END) AS delayed_orders,
    ROUND(
        100.0 * SUM(CASE WHEN delivery_delay_days > 0 THEN 1 ELSE 0 END)/COUNT(*),
        2
    ) AS delayed_orders_pct
FROM orders_clean;

-- Result: 6,534 delivered orders were delayed, representing 6.77% of delivered orders.


-- Query 02: Review score distribution for all delivered orders
-- Business question: What is the review score distribution for all delivered orders?

WITH orders_with_review AS (
    SELECT
        o.order_id,
        r.review_score
    FROM orders_clean o
    JOIN order_reviews_clean r ON o.order_id = r.order_id
)
SELECT review_score,
    COUNT(*) AS count_of_review_score,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percent_of_total
FROM orders_with_review
GROUP BY review_score
ORDER BY review_score DESC;

-- Result: Review score 4 and 5 were the most frequent, 
-- representing almost 80% of all delivered orders.


-- Query 03: Review score distribution for delayed orders
-- Business question: What is the review score distribution for delayed orders?

WITH delayed_orders AS (
    SELECT
        o.order_id,
        o.delivery_delay_days,
        r.review_score
    FROM orders_clean o
    JOIN order_reviews_clean r ON o.order_id = r.order_id
    WHERE o.delivery_delay_days > 0
)
SELECT review_score,
    COUNT(*) AS count_of_review_score,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percent_of_total
FROM delayed_orders
GROUP BY review_score
ORDER BY review_score DESC;

-- Result: 
-- Review score 1 was most frequent, representing 53.78% of delayed orders,
-- Review score 5 was second most frequent, representing 16.55% of delayed orders,
-- Review score 1 and 2 represented together almost 62.5% of delayed orders.


-- Query 04: Review score and low ratings by delivery delay length
-- Business question: How does customer satisfaction change as delivery delay length increases?

WITH delayed_orders_bucket AS (
    SELECT
        o.order_id,
        o.delivery_delay_days,
        r.review_score,
        CASE
                WHEN o.delivery_delay_days BETWEEN 1 AND 7 THEN '1-7 days'
                WHEN o.delivery_delay_days BETWEEN 8 AND 14 THEN '8-14 days'
                WHEN o.delivery_delay_days BETWEEN 15 AND 30 THEN '15-30 days'
                WHEN o.delivery_delay_days BETWEEN 31 AND 60 THEN '31-60 days'
                ELSE '60 days+'
        END AS delay_bucket
    FROM orders_clean o
    JOIN order_reviews_clean r ON o.order_id = r.order_id
    WHERE o.delivery_delay_days > 0
)
SELECT
    delay_bucket,
    COUNT(*) AS number_of_delayed_orders,
    ROUND(
        100.0 * COUNT(*)/ SUM(COUNT(*)) OVER(), 2
    ) AS share_of_delayed_orders_pct,
    ROUND(
        AVG(review_score),2
    ) AS average_review_score,
    ROUND(
        100.0 * (SUM(CASE WHEN review_score IN (1, 2) THEN 1 ELSE 0 END))/COUNT(*),
        2
    ) AS share_of_low_ratings_pct
FROM delayed_orders_bucket
GROUP BY delay_bucket;

-- Result:
-- Average review score generally decreased as delivery delay length increased,
-- especially between the 1-7 days and 31-60 days delay buckets.
-- The 60+ days bucket did not follow the same pattern, which may be related
-- to its small share of delayed orders.
-- The share of low ratings remained high across delay buckets, indicating that
-- delayed deliveries were strongly associated with customer dissatisfaction.


-- Query 05: Order value segment vs review score for delayed orders
-- Business question: Does order value make delayed deliveries more likely to receive low ratings?
-- Average value of orders is 174.56.

SELECT
    value_segment,
    COUNT(*) AS number_of_delayed_orders,
    ROUND(
        AVG(review_score),2
    ) AS average_review_score,
    ROUND(
        SUM(CASE WHEN review_score = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS share_of_score_1_pct,
    ROUND(
        SUM(CASE WHEN review_score IN (1, 2) THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS share_of_low_ratings_pct
FROM delayed_orders_with_value
GROUP BY value_segment;

-- Result:
-- Delayed orders with above-average order value had a higher share of score 1 ratings
-- than delayed orders with below-average order value (57.61% vs 52.26%).
-- They also had a higher share of low ratings, defined as scores 1 and 2
-- (65.20% vs 61.29%).
-- Average review score was lower for delayed orders with above-average order value.


-- Query 06: Final dataset used for Power BI dashboard
-- Technical purpose: Create an analysis-ready export containing delivery status,
-- delay buckets, review scores, order value, and value segments for Power BI visualization.

WITH order_value AS (
    SELECT 
        order_id,
        ROUND(SUM(price + freight_value),2) AS order_value
    FROM order_items_clean
    GROUP BY order_id
),
dashboard_data AS (
    SELECT
        o.order_id,
        o.purchase_timestamp,
        o.delivered_customer_date,
        o.estimated_delivery_date,
        o.delivery_delay_days,
        CASE
            WHEN o.delivery_delay_days > 0 THEN 'Delayed'
            ELSE 'On Time or Early'
        END AS delivery_status,
        CASE
            WHEN o.delivery_delay_days <= 0 THEN 'On Time or Early'
            WHEN o.delivery_delay_days <= 7 THEN '1-7 days'
            WHEN o.delivery_delay_days <= 14 THEN '8-14 days'
            WHEN o.delivery_delay_days <= 30 THEN '15-30 days'
            WHEN o.delivery_delay_days <= 60 THEN '31-60 days'
            ELSE 'More than 60 days'
        END AS delay_bucket,
        CASE
            WHEN o.delivery_delay_days <= 0 THEN 0
            WHEN o.delivery_delay_days <= 7 THEN 1
            WHEN o.delivery_delay_days <= 14 THEN 2
            WHEN o.delivery_delay_days <= 30 THEN 3
            WHEN o.delivery_delay_days <= 60 THEN 4
            ELSE 5
        END AS delay_bucket_order,
        r.review_score,
        ov.order_value
    FROM orders_clean o
    LEFT JOIN order_reviews_clean r 
        ON o.order_id = r.order_id
    LEFT JOIN order_value ov 
        ON o.order_id = ov.order_id
)
SELECT
    *,
    CASE
        WHEN order_value < (SELECT AVG(order_value) FROM dashboard_data) THEN 'Below Average'
        ELSE 'Above Average'
    END AS value_segment
FROM dashboard_data;

-- Result:
-- This query returns the analysis-ready dataset used for the Power BI dashboard export.
