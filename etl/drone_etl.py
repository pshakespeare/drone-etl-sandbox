import os
import json
import pandas as pd
from datetime import datetime
from minio import Minio
import psycopg2
from psycopg2.extras import RealDictCursor
import schedule
import time
import requests

class DroneETL:
    def __init__(self):
        self.minio_client = Minio(
            os.getenv("MINIO_ENDPOINT") + ":9000",
            access_key=os.getenv("MINIO_ACCESS_KEY"),
            secret_key=os.getenv("MINIO_SECRET_KEY"),
            secure=False
        )
        self.db_conn = psycopg2.connect(
            host=os.getenv("POSTGRES_HOST"),
            database=os.getenv("POSTGRES_DB"),
            user=os.getenv("POSTGRES_USER"),
            password=os.getenv("POSTGRES_PASSWORD"),
            cursor_factory=RealDictCursor
        )

    def extract_drone_data(self, api_url):
        """Extract drone traffic data from API"""
        try:
            response = requests.get(api_url)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            print(f"Error extracting data: {str(e)}")
            return None

    def transform_data(self, data):
        """Transform raw drone data into structured format"""
        if not data:
            return None
        
        # Convert to DataFrame for easier manipulation
        df = pd.DataFrame(data)
        
        # Add timestamp column
        df['processed_at'] = datetime.now().isoformat()
        
        # Perform any necessary transformations
        # Example: Convert coordinates, clean data, etc.
        
        return df

    def load_to_minio(self, df, service_type, vendor):
        """Load transformed data to MinIO"""
        if df is None or df.empty:
            return False

        # Create timestamp for folder name
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        folder_name = f"{service_type}-{vendor}-{timestamp}"
        
        # Convert DataFrame to JSON
        json_data = df.to_json(orient='records')
        
        # Create bucket if it doesn't exist
        bucket_name = "drone-data"
        if not self.minio_client.bucket_exists(bucket_name):
            self.minio_client.make_bucket(bucket_name)
        
        # Upload data to MinIO
        object_name = f"{folder_name}/drone_traffic.json"
        self.minio_client.put_object(
            bucket_name,
            object_name,
            json_data.encode('utf-8'),
            len(json_data.encode('utf-8')),
            content_type='application/json'
        )
        
        return True

    def load_to_postgres(self, df):
        """Load transformed data to PostgreSQL"""
        if df is None or df.empty:
            return False

        try:
            cur = self.db_conn.cursor()
            
            # Create table if it doesn't exist
            cur.execute("""
                CREATE TABLE IF NOT EXISTS drone_traffic (
                    id SERIAL PRIMARY KEY,
                    data JSONB,
                    processed_at TIMESTAMP
                )
            """)
            
            # Insert data
            for _, row in df.iterrows():
                cur.execute(
                    "INSERT INTO drone_traffic (data, processed_at) VALUES (%s, %s)",
                    (json.dumps(row.to_dict()), row['processed_at'])
                )
            
            self.db_conn.commit()
            cur.close()
            return True
        except Exception as e:
            print(f"Error loading to PostgreSQL: {str(e)}")
            self.db_conn.rollback()
            return False

    def run_etl(self, api_url, service_type, vendor):
        """Run the complete ETL process"""
        print(f"Starting ETL process for {service_type}-{vendor}")
        
        # Extract
        raw_data = self.extract_drone_data(api_url)
        
        # Transform
        transformed_data = self.transform_data(raw_data)
        
        # Load to MinIO
        minio_success = self.load_to_minio(transformed_data, service_type, vendor)
        
        # Load to PostgreSQL
        pg_success = self.load_to_postgres(transformed_data)
        
        print(f"ETL process completed. MinIO: {minio_success}, PostgreSQL: {pg_success}")

def schedule_etl(api_url, service_type, vendor, interval_minutes=60):
    """Schedule ETL job"""
    etl = DroneETL()
    
    def job():
        etl.run_etl(api_url, service_type, vendor)
    
    # Run immediately
    job()
    
    # Schedule recurring job
    schedule.every(interval_minutes).minutes.do(job)
    
    while True:
        schedule.run_pending()
        time.sleep(1)

if __name__ == "__main__":
    # Example usage
    API_URL = "https://api.example.com/drone-traffic"  # Replace with actual API URL
    SERVICE_TYPE = "traffic-monitoring"
    VENDOR = "drone-vendor"
    
    schedule_etl(API_URL, SERVICE_TYPE, VENDOR) 