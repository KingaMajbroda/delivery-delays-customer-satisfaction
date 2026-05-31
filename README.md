# The Impact of Delivery Delays on Customer Satisfaction

## Short Project Summary
The project goal is to analyze the impact of delivery delays on customer satisfaction.
The project was created to assess whether improvements in logistics performance could contribute to higher customer satisfaction.
The analysis was conducted using SQL and visualized in Power BI.
The results suggest that delivery delays are associated with lower customer satisfaction.

## Business Question / Analytical Goal

### Main Business Question:
How do delivery delays affect customer satisfaction?

### Supporting Analytical Questions:
- What share of delivered orders were delayed?
- What is the review score distribution for all delivered orders and for delayed orders?
- How does customer satisfaction change as delivery delay length increases?
- Does order value make delayed deliveries more likely to receive low ratings?

## Dataset Description and Source
The dataset comes from the Brazilian E-Commerce Public Dataset by Olist.
It contains real commercial data on around 100,000 orders placed between 2016 and 2018 across multiple marketplaces in Brazil.

The project uses three parts of the dataset:
- orders dataset
- order reviews dataset
- order items dataset

Source: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## Tools Used
- SQL
- SQLite
- Power BI

## Repository Contents
- `README.md` - project overview and documentation
- `sql/01_data_preparation.sql` - SQL script used for data cleaning and preparation
- `sql/02_analysis_queries.sql` - main SQL queries used for analysis
- `powerbi_exports/delivery_dashboard_v2.csv` - dataset prepared for dashboard visualization
- `dashboard/delivery_performance_dashboard.pbix` - Power BI dashboard file
- `dashboard/delivery_performance_dashboard.png` - dashboard preview

## Data Preparation
- Selected the relevant tables: orders, order reviews, and order items.
- Created a clean orders table by formatting dates, calculating delivery delay days, and filtering the data to delivered orders.
- Created a clean order items table by keeping the most useful columns.
- Created a clean order reviews table by keeping the most recent review for orders with multiple reviews.
- Created a delayed orders table with order value calculated from item price and freight value.

## Analysis Process
- Calculated the overall share of delivered orders that were delayed.
- Compared the review score distribution for all delivered orders and delayed orders.
- Grouped delayed orders by delay length.
- Analyzed how average review score and the share of low ratings changed by delay length.
- Compared delayed orders by order value segment.
- Prepared the final dataset for Power BI dashboard visualization.

## Key Insights
- Delayed orders represented 6.77% of all delivered orders.
- Review scores 4 and 5 were the most common among all delivered orders, together representing almost 80% of reviews.
- Among delayed orders, review scores 1 and 2 accounted for around 62.5% of reviews, with score 1 alone representing 53.78%.
- Delayed orders accounted for 37% of all reviews with a score of 1, suggesting that delivery delays were strongly associated with customer dissatisfaction.
- Average review score generally decreased as delivery delay length increased, while the share of low ratings increased across most delay groups. 
- Delayed orders with above-average order value had a slightly lower average review score than delayed orders with below-average order value. The difference was relatively small, so this result should be interpreted with caution.

## Recommendations / Business Interpretation
- Improve logistics performance to reduce delivery delays and lower the share of negative customer reviews.
- Strengthen order tracking communication so customers can better monitor delivery status and expected delivery dates.
- Review courier partner performance and prioritize cooperation with the most reliable delivery providers.
- Improve address validation during checkout to reduce delivery problems caused by incomplete or incorrect customer addresses.

## Limitations
- The 31-60 days and 60+ days delay groups represented a smaller share of delayed orders, so patterns observed in these groups should be interpreted with caution.
- Some records had missing values in key fields such as delivery dates or review scores, which may affect the completeness of the analysis.
- Some orders had more than one review, so only the most recent review was kept for analysis.
- Order value segmentation was based on the average order value, which is a simple threshold and may not fully reflect different customer spending patterns.
- The analysis shows associations between delivery delays and review scores, but it does not prove direct causation.

## How to View the Project

1. Open `README.md` to understand the project goal, dataset, key insights, and recommendations.
2. Review `sql/01_data_preparation.sql` to see how the data was cleaned and prepared.
3. Review `sql/02_analysis_queries.sql` to see the main analytical queries and results.
4. Open `dashboard/delivery_performance_dashboard.png` to preview the Power BI dashboard.
5. Open `dashboard/delivery_performance_dashboard.pbix` in Power BI Desktop to explore the interactive dashboard.