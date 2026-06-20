select * from amazon limit 10

--Q1. Revenue and order count by category
SELECT category,
       SUM(amount) AS total_revenue,
       COUNT(*) AS order_count,
       ROUND(AVG(amount)::numeric, 2) AS avg_order_value
FROM amazon sales
GROUP BY category
ORDER BY total_revenue DESC;

--Q2. Monthly revenue trend
SELECT month,
       SUM(amount) AS total_revenue,
       COUNT(*) AS order_count
FROM amazon sales
GROUP BY month
ORDER BY
    CASE month
        WHEN 'January' THEN 1 WHEN 'February' THEN 2 WHEN 'March' THEN 3
        WHEN 'April' THEN 4 WHEN 'May' THEN 5 WHEN 'June' THEN 6
        WHEN 'July' THEN 7 WHEN 'August' THEN 8 WHEN 'September' THEN 9
        WHEN 'October' THEN 10 WHEN 'November' THEN 11 WHEN 'December' THEN 12
    END;

--Q3. Order status mix
SELECT status,
       COUNT(*) AS order_count,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM amazon sales), 2) AS pct_of_orders
FROM amazon sales
GROUP BY status
ORDER BY order_count DESC;

--Q4. Cancellation rate by fulfilment type
SELECT is_amazon_fulfilled,
       COUNT(*) AS total_orders,
       SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
       ROUND(100.0 * SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS cancel_pct
FROM amazon sales
GROUP BY is_amazon_fulfilled;	

--Q5. Top 10 states by revenue
SELECT ship_state,
       SUM(amount) AS total_revenue,
       COUNT(*) AS order_count
FROM amazon sales
GROUP BY ship_state
ORDER BY total_revenue DESC
LIMIT 10;

--Q6. Promotion impact on average order value
SELECT CASE WHEN promotion_ids = 'No Promotion' THEN FALSE ELSE TRUE END AS has_promotion,
       ROUND(AVG(amount):: numeric, 2) AS avg_order_value,
       COUNT(*) AS order_count
FROM amazon sales
GROUP BY CASE WHEN promotion_ids = 'No Promotion' THEN FALSE ELSE TRUE END;

--Q7. Revenue band distribution
SELECT revenue_band,
       COUNT(*) AS order_count,
       SUM(amount) AS total_revenue
FROM amazon sales
GROUP BY revenue_band;

--Q8. Top 10 SKUs by revenue
SELECT sku,
       category,
       SUM(amount) AS total_revenue,
       SUM(qty) AS total_units,
       COUNT(*) AS order_count
FROM amazon sales
GROUP BY sku, category
ORDER BY total_revenue DESC
LIMIT 10;

--Q9. Overall KPIs (single row — for dashboard KPI cards)
SELECT
    SUM(amount) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(amount):: numeric, 2) AS avg_order_value,
    SUM(qty) AS total_units_sold,
    ROUND(100.0 * SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS cancel_rate_pct
FROM amazon sales;

ALTER TABLE amazon
ADD COLUMN IF NOT EXISTS month_sort INT;

UPDATE amazon
SET month_sort = CASE month
    WHEN 'January'   THEN 1
    WHEN 'February'  THEN 2
    WHEN 'March'     THEN 3
    WHEN 'April'     THEN 4
    WHEN 'May'       THEN 5
    WHEN 'June'      THEN 6
    WHEN 'July'      THEN 7
    WHEN 'August'    THEN 8
    WHEN 'September' THEN 9
    WHEN 'October'   THEN 10
    WHEN 'November'  THEN 11
    WHEN 'December'  THEN 12
END;


UPDATE amazon sales 
SET revenue_band = 'Low' 
WHERE revenue_band IS NULL AND amount = 0;

SELECT revenue_band, COUNT(*) as order_count
FROM amazon sales
GROUP BY revenue_band
ORDER BY order_count DESC;



ALTER TABLE amazon 
ADD COLUMN IF NOT EXISTS promotion VARCHAR(10);
UPDATE amazon sales
SET promotion = CASE
    WHEN promotion_ids != 'No Promotion' THEN 'Yes'
    WHEN promotion_ids  = 'No Promotion' THEN 'No'
END;


