# BrightTV Viewership Analytics
### Overview of the Case Study

This project presents an end-to-end analysis of BrightTV’s user profiles and viewership data to support the CEO’s objective of growing the subscription base.
The analysis focuses on understanding user behavior, content consumption patterns, and engagement drivers to provide actionable insights for the Customer Value Management (CVM) team.

### Project Objectives

The analysis aims to answer key business questions:

* What are the key user and viewership trends?
* Which factors influence content consumption?
* What content strategies can increase engagement on low-activity days?
* What initiatives can drive user growth and retention?
  
### How the Case Study Was Conducted

### 1. Data Ingestion & Setup
* Loaded raw datasets into Databricks (Lakehouse environment)
* Combined two primary data sources:
* User Profile Data (demographics, location)
* Viewership Data (sessions, channels, timestamps, duration)
  
### 2. Data Cleaning & Quality Checks
* Performed null handling (replacing “None” with meaningful categories)
* Removed and validated duplicate session records
* Standardized categorical fields (e.g., Province, Race, Channel)
* Converted timestamps from UTC to South African time (GMT+2)
* Cleaned and transformed session duration into usable numeric format

### 3. Feature Engineering

Created analytical features to enhance insights:

#### 3.1 Time-Based Features
* Day of week, Month
* Time buckets (Morning, Afternoon, Evening, Night)
* Weekday vs Weekend classification
* Month pattern (Beginning, Mid, End)


#### 3.2 User & Behavioral Features
* Active days per user
* Session frequency
* Viewer segmentation (Light → Super viewers)
#### 3.3 Business Metrics
* Total Watch Time (hours)
* Average Session Duration
* Sessions per User
* Daily Active Users (DAU) & Monthly Active Users (MAU)
* Retention Rate
* Stickiness Ratio (DAU / MAU)
* Churn Indicator
* Growth Rate

### 4. Exploratory Data Analysis (EDA)

#### 4.1 Used SQL to analyze:

* User engagement trends over time (daily, weekly, monthly)
* Content consumption by channel
* Viewing behavior across time bucket
* Demographic analysis (age, gender, province)
* Retention and churn patterns
* User activity distribution and engagement levels

### 5. Data Visualization & Reporting

Tools used:

* Power BI
* Microsoft Excel (Pivot Tables & Charts)
* GoogleLooker Studio
* loveable https://shanay.lovable.app/

### Visualized:

* User growth trends (DAU, MAU)
* Engagement patterns by time of day
* Channel performance
* Retention and churn metrics
* Demographic distribution
* Viewer segmentation (watch categories)
  
### Key Insights
#### User & Engagement Insights
* A large portion of users are low-frequency viewers, indicating opportunities to improve engagement
* Retention is driven by repeat viewing behavior, not just acquisition
* Stickiness ratio suggests moderate platform engagement, with room for improvement
  
#### Time-Based Insights
* Peak consumption occurs during afternoon and evening hours,  aligning with leisure time
* Weekdays show higher engagement compared to weekends
* Mondays and Nights experience significantly lower consumption, highlighting optimization opportunities
  
#### Content Performance Insights
* A few channels dominate total viewership (high concentration)
* Underperforming channels indicate content mismatch or low visibility
  
#### Demographic Insights
* Engagement varies significantly across provinces and age groups
* Younger users tend to have higher session frequency but shorter durations
* Certain regions show lower activity, indicating market expansion opportunities
  
### Recommendations
#### Content Strategy
* Promote high-performing content during low-activity periods
* Introduce targeted content recommendations based on gender
* Optimize underperforming channels through repositioning or replacement
  
#### Engagement Optimization
* Introduce personalized notifications during low engagement times
* Create binge-worthy content blocks to increase session duration
* Implement watch streaks or rewards systems
  
#### User Growth Strategy
* Target low-activity regions with localized content
* Leverage referral programs to acquire new users
* Improve onboarding experience to increase early engagement

#### Retention Strategy
* Focus on users with low session counts (early churn risk)
* Use behavioral segmentation for targeted campaigns
* Monitor churn indicators and intervene proactively
  
### Tools Used In Overall Case Study
* SQL
* Databricks
* Data Visualization
* Power BI & Google Looker Studio
* Microsoft Excel
* Planning & Presentation
* Draw.io (Data Flow Diagrams)
* Microsoft PowerPoint/Canva
