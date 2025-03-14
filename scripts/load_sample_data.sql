-- Create a table for drone deliveries
CREATE TABLE IF NOT EXISTS drone_deliveries (
    id SERIAL PRIMARY KEY,
    drone_id VARCHAR(50),
    company_name VARCHAR(100),
    delivery_type VARCHAR(50),
    status VARCHAR(50),
    pickup_location JSONB,
    delivery_location JSONB,
    altitude_meters DECIMAL(10,2),
    speed_kmh DECIMAL(10,2),
    payload_weight_kg DECIMAL(10,2),
    weather_conditions JSONB,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data for different drone delivery companies
INSERT INTO drone_deliveries (drone_id, company_name, delivery_type, status, pickup_location, delivery_location, altitude_meters, speed_kmh, payload_weight_kg, weather_conditions, start_time, end_time)
VALUES
-- Wing Drones (Alphabet)
('WING-001', 'Wing', 'Food Delivery', 'Completed', 
'{"lat": 37.7749, "lng": -122.4194, "address": "123 Market St, San Francisco"}',
'{"lat": 37.7833, "lng": -122.4167, "address": "456 Mission St, San Francisco"}',
120.5, 45.0, 2.5,
'{"temperature": 18.5, "wind_speed": 12.0, "visibility": "Good"}',
'2024-03-20 10:00:00', '2024-03-20 10:15:00'),

-- Amazon Prime Air
('AMZN-001', 'Amazon Prime Air', 'Package Delivery', 'In Progress',
'{"lat": 47.6062, "lng": -122.3321, "address": "Amazon HQ, Seattle"}',
'{"lat": 47.6152, "lng": -122.3221, "address": "789 Pine St, Seattle"}',
90.0, 40.0, 3.2,
'{"temperature": 15.0, "wind_speed": 8.0, "visibility": "Good"}',
'2024-03-20 11:00:00', NULL),

-- Zipline
('ZIP-001', 'Zipline', 'Medical Supply', 'Completed',
'{"lat": -1.2921, "lng": 36.8219, "address": "Medical Center, Nairobi"}',
'{"lat": -1.2974, "lng": 36.8065, "address": "Rural Clinic, Nairobi"}',
150.0, 110.0, 1.8,
'{"temperature": 25.0, "wind_speed": 15.0, "visibility": "Good"}',
'2024-03-20 09:00:00', '2024-03-20 09:30:00'),

-- UPS Flight Forward
('UPS-001', 'UPS Flight Forward', 'Package Delivery', 'Scheduled',
'{"lat": 33.7490, "lng": -84.3880, "address": "UPS Hub, Atlanta"}',
'{"lat": 33.7600, "lng": -84.3900, "address": "Customer Location, Atlanta"}',
100.0, 35.0, 4.5,
'{"temperature": 22.0, "wind_speed": 10.0, "visibility": "Good"}',
'2024-03-20 14:00:00', NULL),

-- Flytrex
('FLY-001', 'Flytrex', 'Food Delivery', 'Completed',
'{"lat": 32.7767, "lng": -96.7970, "address": "Restaurant, Dallas"}',
'{"lat": 32.7833, "lng": -96.8000, "address": "Customer Home, Dallas"}',
80.0, 38.0, 2.0,
'{"temperature": 20.0, "wind_speed": 9.0, "visibility": "Good"}',
'2024-03-20 12:00:00', '2024-03-20 12:20:00');

-- Generate 100 more records with random data
INSERT INTO drone_deliveries (drone_id, company_name, delivery_type, status, pickup_location, delivery_location, altitude_meters, speed_kmh, payload_weight_kg, weather_conditions, start_time, end_time)
SELECT 
    CASE 
        WHEN company = 'Wing' THEN 'WING-' || LPAD(ROW_NUMBER() OVER (PARTITION BY company ORDER BY RANDOM())::TEXT, 3, '0')
        WHEN company = 'Amazon Prime Air' THEN 'AMZN-' || LPAD(ROW_NUMBER() OVER (PARTITION BY company ORDER BY RANDOM())::TEXT, 3, '0')
        WHEN company = 'Zipline' THEN 'ZIP-' || LPAD(ROW_NUMBER() OVER (PARTITION BY company ORDER BY RANDOM())::TEXT, 3, '0')
        WHEN company = 'UPS Flight Forward' THEN 'UPS-' || LPAD(ROW_NUMBER() OVER (PARTITION BY company ORDER BY RANDOM())::TEXT, 3, '0')
        ELSE 'FLY-' || LPAD(ROW_NUMBER() OVER (PARTITION BY company ORDER BY RANDOM())::TEXT, 3, '0')
    END as drone_id,
    company as company_name,
    delivery_type,
    status,
    jsonb_build_object(
        'lat', base_lat + (RANDOM() * 0.1 - 0.05),
        'lng', base_lng + (RANDOM() * 0.1 - 0.05),
        'address', 'Sample Address ' || ROW_NUMBER() OVER (ORDER BY RANDOM())
    ) as pickup_location,
    jsonb_build_object(
        'lat', base_lat + (RANDOM() * 0.1 - 0.05),
        'lng', base_lng + (RANDOM() * 0.1 - 0.05),
        'address', 'Sample Address ' || ROW_NUMBER() OVER (ORDER BY RANDOM())
    ) as delivery_location,
    (RANDOM() * 100 + 50)::DECIMAL(10,2) as altitude_meters,
    (RANDOM() * 50 + 30)::DECIMAL(10,2) as speed_kmh,
    (RANDOM() * 3 + 1)::DECIMAL(10,2) as payload_weight_kg,
    jsonb_build_object(
        'temperature', (RANDOM() * 20 + 15)::DECIMAL(10,2),
        'wind_speed', (RANDOM() * 20 + 5)::DECIMAL(10,2),
        'visibility', CASE WHEN RANDOM() > 0.1 THEN 'Good' ELSE 'Poor' END
    ) as weather_conditions,
    start_time,
    CASE WHEN status = 'Completed' THEN start_time + (RANDOM() * 30 + 10) * INTERVAL '1 minute'
         ELSE NULL END as end_time
FROM (
    SELECT 
        unnest(ARRAY['Wing', 'Amazon Prime Air', 'Zipline', 'UPS Flight Forward', 'Flytrex']) as company,
        unnest(ARRAY['Food Delivery', 'Package Delivery', 'Medical Supply', 'Express Delivery', 'Food Delivery']) as delivery_type,
        unnest(ARRAY['Completed', 'In Progress', 'Scheduled', 'Failed', 'Completed']) as status,
        unnest(ARRAY[37.7749, 47.6062, -1.2921, 33.7490, 32.7767]) as base_lat,
        unnest(ARRAY[-122.4194, -122.3321, 36.8219, -84.3880, -96.7970]) as base_lng,
        generate_series(
            '2024-03-20 00:00:00'::timestamp,
            '2024-03-20 23:59:59'::timestamp,
            '1 hour'::interval
        ) as start_time
) t
CROSS JOIN generate_series(1, 20)  -- Generate 20 records for each combination
LIMIT 100;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_drone_deliveries_company ON drone_deliveries(company_name);
CREATE INDEX IF NOT EXISTS idx_drone_deliveries_status ON drone_deliveries(status);
CREATE INDEX IF NOT EXISTS idx_drone_deliveries_start_time ON drone_deliveries(start_time);
CREATE INDEX IF NOT EXISTS idx_drone_deliveries_drone_id ON drone_deliveries(drone_id); 