import os
import sys
from datetime import datetime
from etl.drone_etl import DroneETL

def main():
    # Get environment variables
    api_url = os.getenv("DRONE_API_URL")
    service_type = os.getenv("SERVICE_TYPE", "traffic-monitoring")
    vendor = os.getenv("VENDOR", "drone-vendor")
    
    if not api_url:
        print("Error: DRONE_API_URL environment variable is not set")
        sys.exit(1)
    
    # Initialize and run ETL
    etl = DroneETL()
    etl.run_etl(api_url, service_type, vendor)

if __name__ == "__main__":
    main() 