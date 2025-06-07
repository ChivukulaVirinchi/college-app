# JOSAA Counselling Helper

A comprehensive Phoenix LiveView application designed to help JEE students make informed decisions during JOSAA (Joint Seat Allocation Authority) counselling. Provides real-time filtering and analysis of engineering colleges and programs.

## 🎯 Why This App?

JOSAA counselling involves **120+ colleges** and **1000+ programs** with complex cutoff patterns. Students often struggle with:
- Finding colleges within their rank range
- Comparing programs across different institutes
- Understanding cutoff trends and making strategic choices
- Balancing dream colleges vs safe options

This app solves these problems with **intelligent rank-based filtering** and **real-time data analysis**.

## ✨ Key Features

### 🔍 Smart Rank Filtering
- Enter your JEE rank to see personalized admission chances
- Color-coded results: Green (Safe), Orange (Possible), Red (Difficult)
- Advanced algorithms considering college type and rank variations

### 🏛️ College Explorer
- Browse 120+ JOSAA colleges (IITs, NITs, IIITs, GFTIs)
- Real-time filtering by location, NIRF ranking, establishment year
- Detailed college information with historical cutoffs

### 📚 Program Discovery
- Explore all engineering branches and specializations
- Find programs you're eligible for across all colleges
- Compare similar programs (CSE vs IT vs CSE with specialization)

### 📊 Cutoff Analysis
- Historical cutoff trends with interactive charts
- Category-wise cutoffs (All India, Home State, Other State)
- Predict future cutoffs based on trends

### ⚡ Real-time Performance
- Instant filtering across thousands of records
- No page reloads - pure LiveView experience


## 🚀 Technology Showcase

This application serves as an **advanced demonstration of [LiveTable](https://hex.pm/packages/live_table)** - a powerful library for building real-time, filterable data tables in Phoenix LiveView.

### LiveTable Features Demonstrated:
- **Complex Custom Filters**: Rank-based eligibility, multi-select dropdowns
- **Real-time Search**: Instant filtering across large datasets
- **Custom Components**: Card layouts, custom headers, advanced UI
- **Performance Optimization**: Efficient queries with joins and subqueries
- **Advanced Transformers**: Custom query transformations for business logic

## 🛠️ Getting Started

### Installation

```bash
# Clone the repository
git clone https://github.com/ChivukulaVirinchi/college-app
cd college-app

# Install dependencies
mix deps.get

# Setup database and seed data
mix setup

# Start the Phoenix server
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000) to start exploring colleges and programs!

## 📋 Usage Guide

### For Students:
1. **Enter Your Rank**: Use the rank filter on any page to see personalized results
2. **Explore Colleges**: Browse colleges by type, location, and rankings
3. **Discover Programs**: Find engineering branches you're eligible for
4. **Analyze Trends**: Study historical cutoffs to make informed choices
5. **Compare Options**: Use favorites and comparison features

### For Developers:
This app demonstrates production-ready patterns for:
- Complex LiveView applications
- Advanced Ecto queries
