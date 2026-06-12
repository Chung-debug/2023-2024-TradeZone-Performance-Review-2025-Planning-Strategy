# TradeZone Performance Review & 2025 Strategy Planning 

**An executive data analysis on growth, seller bottlenecks, and revenue retention for TradeZone Nigeria.**

---

### Project Overview
This project focuses on evaluating **TradeZone's e-commerce performance between 2023 and 2024** to guide strategic decisions for the upcoming 2025 fiscal planning cycle. 

While TradeZone achieved massive customer acquisition growth across major Nigerian markets (spearheaded by Lagos and Abuja), the platform faces a hidden leak: **operational inefficiencies in seller fulfillment are causing declining conversion rates and putting major revenue segments at risk**. This project uncovers those bottlenecks and translates raw transaction data into a concrete, executive-level recovery strategy.

---

### Key Insights Discovered

#### 1. High Acquisition ≠ High Conversion 
*   **The Leak:** Despite phenomenal initial signup traction across 5 major Nigerian states, the **30-day conversion rate is sitting at a low average of 39.48%**.
*   **The Impact:** TradeZone is burning marketing budget to open the front door, but the vast majority of users leave without purchasing a single item within their first month. 

#### 2. Fulfillment Speed Holds the Crown for Customer Satisfaction 
*   **The Contrast:** Top-performing sellers complete orders in an average of **100.53 hours**, pulling in a decent **3.6 customer rating**. 
*   **The Problem:** Slower sellers are driving down the platform's overall reputation. Products sitting at a **"Low Rated" level (below 3.0) only account for ₦85,846,320.55 in total revenue**. If we leave these lagging storefronts unchecked, they will heavily dilute TradeZone's overall sales potential.

#### 3. We Are Carried by "High Spenders" 
*   **The Elephant in the Room:** Customers spending ₦100,000 or more make up **over 77% of the total customer base**. 
*   **The Risk:** This single segment contributes **₦417,098,017.96** of total platform revenue. If operational delays frustrate even a tiny percentage of these power buyers, the financial impact on the business will be devastating.

---

### Data Cleaning & Quality Control
Real-world data is messy. During the data preparation phase, two critical data-integrity issues were fixed:
1.  **Mismatch in Order Totals:** Flagged and isolated records where the `total_amount` in the main orders table deviated from the sum of its `line_total` counterparts by more than ₦10. These were excluded from revenue calculations to prevent skewed numbers.
2.  **Invalid Review Ratings:** Standardized rogue data points existing outside the standard 1–5 range by compressing outlier inputs (e.g., pulling -1 up to 1, and 7 down to 5) so the categorical weight was preserved without breaking aggregation metrics.

---

### Strategic Recommendations
To shift focus from pure acquisition to strict seller standards and customer retention, the following implementations have been proposed:

*   **Enforce a strict Seller Fulfillment SLA:** Enforce a maximum **48-hour dispatch rule**. Sellers failing to hit this metric over a 30-day window will automatically have their visibility deprioritized in the search algorithm. *(Target: 15% fulfillment speed improvement in 60–90 days)*.
*   **Targeted 30-Day "First Purchase" Campaigns:** Reallocate **20% of the customer acquisition budget** into high-intent email and push campaigns. New users will receive a limited-time free shipping discount if they buy within their first 14 days. *(Target: Improve 30-day conversion rate by 10% within 60 days)*.

---

### What the Data *Cannot* Tell Us (Yet)
While the transactional database perfectly captures *what* and *when* things are bought, it lacks user behavioral context. It cannot show **why** new users drop off within 30 days. 

**Next Steps:** To patch this gap, the next phase of this project requires integrating web/app usage clickstream patterns to find exactly where users get stuck or back out before checking out.

---
### Built With
*   **SQL** - Data Extraction & Financial Integrity Cleaning
*   **SQL** - Data Aggregation and Trend Analysis
*   **Markdown** - Executive Reporting

*Analysis by Chung Yok — April 2026*
