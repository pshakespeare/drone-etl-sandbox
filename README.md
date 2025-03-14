# DroneETL-Sandbox

A modern data pipeline testing environment for processing and analyzing drone delivery traffic data. This project provides a sandbox environment for testing ETL pipelines, data warehousing, and real-time analytics using industry-standard tools and best practices.

## 🚀 Project Overview

This sandbox environment provides a complete setup for testing and developing ETL pipelines for drone delivery traffic data. The system is designed to simulate real-world scenarios by collecting drone delivery data from various companies, processing it, and storing it in both a structured database and a data lake for different analytical purposes.

### Key Features
- Real-time data processing pipeline
- Dual storage strategy (PostgreSQL + MinIO)
- RESTful API for data access
- Comprehensive monitoring and logging
- Sample dataset for testing and development
- Docker-based deployment

### Technical Stack
- **Backend**: Python 3.11, Flask
- **Database**: PostgreSQL 15
- **Storage**: MinIO (S3-compatible)
- **Containerization**: Docker & Docker Compose
- **Data Format**: JSON/JSONB
- **API**: RESTful endpoints

## 🛠️ System Components

- **Flask API Service**: RESTful API service for querying data and monitoring the system
- **PostgreSQL Database**: Structured storage for real-time querying and analysis
- **MinIO Data Lake**: Object storage for raw and processed data files
- **ETL Pipeline**: Automated data processing workflow
- **Sample Dataset**: Pre-loaded drone delivery data from major companies

## 🏗️ Architecture Overview

The system follows a modern data architecture pattern:
1. **Data Collection**: ETL service fetches data from drone APIs
2. **Data Processing**: Transforms raw data into structured format
3. **Dual Storage**:
   - PostgreSQL for real-time querying and operational analytics
   - MinIO for historical data and batch processing
4. **API Layer**: Flask service for data access and system monitoring

## 📋 Prerequisites

- Docker and Docker Compose (for containerized deployment)
- Python 3.11 (if running locally)
- Minimum 4GB RAM recommended
- At least 10GB free disk space

## 🚀 Getting Started

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/drone-etl-sandbox.git
   cd drone-etl-sandbox
   ```

2. Create a `.env` file in the root directory with the following variables:
   ```ini
   # API Configuration
   DRONE_API_URL=your_drone_api_url    # External drone data API endpoint
   SERVICE_TYPE=your_service_type      # e.g., delivery, monitoring
   VENDOR=your_vendor                  # e.g., wing, amazon, zipline

   # Optional Configuration
   ETL_INTERVAL=3600                   # ETL run interval in seconds (default: 1 hour)
   DEBUG=False                         # Enable debug mode
   ```

3. Start the environment:
   ```bash
   docker-compose up -d
   ```

4. Verify the setup:
   ```bash
   # Check if all services are running
   docker-compose ps

   # Verify sample data was loaded (should show 105 records)
   docker-compose exec postgres psql -U drone_user -d drone_db -c "SELECT COUNT(*) FROM drone_deliveries;"

   # Check API health
   curl http://localhost:8000/health
   ```

## 🔧 Service Details

### API Service (Flask)
- **Port**: 8000
- **Purpose**: Provides HTTP endpoints for data access and system monitoring
- **Features**:
  - SQL query execution
  - Health monitoring
  - MinIO object access
  - CORS enabled for web applications

### MinIO Object Storage
- **Console**: http://localhost:9001
- **Credentials**: minioadmin/minioadmin
- **Purpose**: Data lake storage for raw and processed data
- **Features**:
  - Object versioning
  - S3-compatible API
  - Web-based console
  - Bucket notifications

### PostgreSQL Database
- **Port**: 5432
- **Credentials**: drone_user/drone_password
- **Purpose**: Structured storage for real-time analytics
- **Features**:
  - JSONB support for flexible data storage
  - Indexed fields for fast querying
  - Temporal data support

## 📊 Sample Data Details

The environment includes a comprehensive dataset of drone delivery operations:

### Pre-loaded Records (105 total)
- **Core Records**: 5 detailed examples from major companies
- **Generated Data**: 100 synthetic records based on realistic patterns
- **Time Range**: 24-hour period (2024-03-20)
- **Geographic Coverage**: Multiple cities worldwide

### Featured Companies

1. **Wing (Alphabet)**
   - Region: San Francisco, CA
   - Specialization: Food delivery
   - Typical altitude: 100-120m
   - Speed range: 40-50 km/h

2. **Amazon Prime Air**
   - Region: Seattle, WA
   - Specialization: Package delivery
   - Typical altitude: 80-100m
   - Speed range: 35-45 km/h

3. **Zipline**
   - Region: Nairobi, Kenya
   - Specialization: Medical supply delivery
   - Typical altitude: 130-150m
   - Speed range: 90-110 km/h

4. **UPS Flight Forward**
   - Region: Atlanta, GA
   - Specialization: Package delivery
   - Typical altitude: 90-110m
   - Speed range: 30-40 km/h

5. **Flytrex**
   - Region: Dallas, TX
   - Specialization: Food delivery
   - Typical altitude: 70-90m
   - Speed range: 35-45 km/h

### Data Structure Details

The `drone_deliveries` table schema:

#### Core Fields
- `id`: Unique identifier (SERIAL PRIMARY KEY)
- `drone_id`: Company-specific identifier (e.g., WING-001, AMZN-001)
- `company_name`: Operating company name

#### Delivery Information
- `delivery_type`: Categories:
  - Food Delivery
  - Package Delivery
  - Medical Supply
  - Express Delivery
- `status`: States:
  - Completed
  - In Progress
  - Scheduled
  - Failed

#### Location Data (JSONB)
```json
{
  "lat": 37.7749,
  "lng": -122.4194,
  "address": "123 Market St, San Francisco"
}
```

#### Technical Data
- `altitude_meters`: Operating altitude (50-150m range)
- `speed_kmh`: Flight speed (30-80 km/h range)
- `payload_weight_kg`: Cargo weight (1-4.5 kg range)

#### Weather Data (JSONB)
```json
{
  "temperature": 18.5,
  "wind_speed": 12.0,
  "visibility": "Good"
}
```

#### Temporal Data
- `start_time`: Delivery initiation
- `end_time`: Delivery completion (NULL for in-progress)
- `created_at`: Record creation timestamp

### Example Queries and Analysis

1. **Delivery Performance by Company**
   ```sql
   SELECT company_name, COUNT(*) as delivery_count 
   FROM drone_deliveries 
   GROUP BY company_name;
   ```
   - Purpose: Compare delivery volumes across companies
   - Use case: Market share analysis

2. **Delivery Time Analysis**
   ```sql
   SELECT 
       company_name, 
       ROUND(AVG(EXTRACT(EPOCH FROM (end_time - start_time))/60)::numeric, 2) as avg_delivery_time_minutes
   FROM drone_deliveries 
   WHERE status = 'Completed' 
   GROUP BY company_name;
   ```
   - Purpose: Compare delivery efficiency
   - Use case: Performance optimization

3. **Weather Impact Analysis**
   ```sql
   SELECT 
       weather_conditions->>'visibility' as visibility,
       status,
       COUNT(*) as count
   FROM drone_deliveries 
   GROUP BY weather_conditions->>'visibility', status
   ORDER BY visibility, status;
   ```
   - Purpose: Analyze weather effects on delivery success
   - Use case: Risk assessment

4. **Active Fleet Monitoring**
   ```sql
   SELECT 
       drone_id,
       company_name,
       pickup_location->>'address' as pickup,
       delivery_location->>'address' as destination,
       speed_kmh,
       altitude_meters
   FROM drone_deliveries 
   WHERE status = 'In Progress';
   ```
   - Purpose: Real-time fleet monitoring
   - Use case: Operations management

5. **Payload Analysis**
   ```sql
   SELECT 
       company_name,
       ROUND(AVG(payload_weight_kg)::numeric, 2) as avg_weight,
       ROUND(MIN(payload_weight_kg)::numeric, 2) as min_weight,
       ROUND(MAX(payload_weight_kg)::numeric, 2) as max_weight
   FROM drone_deliveries
   GROUP BY company_name;
   ```
   - Purpose: Analyze cargo patterns
   - Use case: Capacity planning

## 🔄 ETL Process Details

The ETL pipeline processes drone delivery data in three phases:

### 1. Extract
- Fetches data from configured drone APIs
- Handles rate limiting and pagination
- Validates raw data integrity

### 2. Transform
- Standardizes data formats
- Enriches with calculated fields
- Validates business rules
- Handles missing data

### 3. Load
- **MinIO Storage**:
  - Path format: `<service-type>-<vendor>-<timestamp>/drone_traffic.json`
  - Preserves raw data
  - Enables historical analysis
- **PostgreSQL Storage**:
  - Structured for real-time queries
  - Indexed for performance
  - Supports operational analytics

## 🔍 Monitoring and Maintenance

### Health Checks
- API health: http://localhost:8000/health
- MinIO console: http://localhost:9001
- PostgreSQL logs: `docker-compose logs postgres`

### Common Operations
1. **View Service Logs**:
   ```bash
   docker-compose logs [service_name]
   ```

2. **Check Environment**:
   ```bash
   docker-compose exec api env
   ```

3. **Database Access**:
   ```bash
   docker-compose exec postgres psql -U drone_user -d drone_db
   ```

4. **Reload Sample Data**:
   ```bash
   docker-compose restart data-loader
   ```

### Troubleshooting Guide

1. **Service Access Issues**:
   - MinIO (ports 9000/9001): Check port conflicts
   - PostgreSQL (port 5432): Verify service readiness
   - API (port 8000): Check Flask logs

2. **Data Loading Issues**:
   - Check data-loader logs
   - Verify PostgreSQL connection
   - Confirm environment variables

3. **Performance Issues**:
   - Monitor container resources
   - Check database indexes
   - Review query performance

4. **Common Error Resolution**:
   - Container fails: Check logs and restart service
   - Database connection: Wait for PostgreSQL initialization
   - Missing data: Reload sample dataset

