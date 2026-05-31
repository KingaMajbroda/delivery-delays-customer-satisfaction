-- Data preparation for the Impact of Delivery Delays on Customer Satisfaction project.
-- Source tables used in this analysis:
-- 1. orders
-- 2. order_items
-- 3. order_reviews
--
-- The goal of this script is to create cleaned and analysis-ready tables 
-- used for SQL analysis and Power BI dashboard preparation.

-- Query 01: Create clean orders table
-- Purpose: Keep only delivered orders with complete delivery dates 
-- and calculate delivery delay.

DROP TABLE IF EXISTS orders_clean;

CREATE TABLE orders_clean AS
SELECT 
    order_id,
    order_status,
    date(order_purchase_timestamp) AS purchase_timestamp,
    date(order_delivered_customer_date) AS delivered_customer_date,
    date(order_estimated_delivery_date) AS estimated_delivery_date,
    julianday(date(order_delivered_customer_date)) - julianday(date(order_estimated_delivery_date)) AS delivery_delay_days
FROM orders
WHERE order_status = 'delivered' 
    AND date(order_delivered_customer_date) IS NOT NULL;


-- Query 02: Create clean order items table
-- Purpose: Keep price and freight value columns for order value analysis.

DROP TABLE IF EXISTS order_items_clean;

CREATE TABLE order_items_clean AS
SELECT 
    order_id,
    order_item_id,
    price,
    freight_value
FROM order_items;


-- Query 03: Create clean order reviews table.
-- Purpose: Keep only the most recent review for each order.

DROP TABLE IF EXISTS order_reviews_clean;

CREATE TABLE order_reviews_clean AS
WITH ranked_reviews AS (
    SELECT 
        order_id,
        review_id,
        review_score,
        date(review_creation_date) AS review_date,
        ROW_NUMBER() OVER ( 
            PARTITION BY order_id 
            ORDER BY date(review_creation_date) DESC, review_id DESC
        ) AS rn
        FROM order_reviews
)
SELECT
    order_id,
    review_id,
    review_score,
    review_date
FROM ranked_reviews
WHERE rn = 1;


-- Query 04: Create helper table for delayed orders
-- Purpose: Keep only delayed orders.

DROP TABLE IF EXISTS delayed_orders;

CREATE TABLE delayed_orders AS
SELECT order_id,
    delivery_delay_days
FROM orders_clean
WHERE delivery_delay_days > 0;


-- Query 05: Create delayed orders with value table
-- Purpose: Add order value, delivery delay, review score, and value segment
-- for delayed orders.
-- The threshold 174.56 represents the average order value in the dataset.

DROP TABLE IF EXISTS delayed_orders_with_value;

CREATE TABLE delayed_orders_with_value AS
WITH order_value AS (
    SELECT 
        order_id,
        SUM(price + freight_value) AS order_value
    FROM order_items_clean
    GROUP BY order_id
)
SELECT 
    d.order_id,
    ov.order_value,
    r.review_score,
    d.delivery_delay_days,
    CASE
        WHEN ov.order_value < 174.56 THEN 'Below average'
        ELSE 'Above average'
    END AS value_segment
FROM delayed_orders d
JOIN order_value ov ON ov.order_id = d.order_id
JOIN order_reviews_clean r ON r.order_id = d.order_id;