from flask import Flask, jsonify, request
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor
from minio import Minio
import os
from datetime import datetime
import json

app = Flask(__name__)
CORS(app)

# Database connection
def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST"),
        database=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
        cursor_factory=RealDictCursor
    )

# MinIO client
minio_client = Minio(
    os.getenv("MINIO_ENDPOINT") + ":9000",
    access_key=os.getenv("MINIO_ACCESS_KEY"),
    secret_key=os.getenv("MINIO_SECRET_KEY"),
    secure=False
)

@app.route("/")
def root():
    return jsonify({"message": "Welcome to Drone Traffic API"})

@app.route("/health")
def health_check():
    try:
        conn = get_db_connection()
        conn.close()
        return jsonify({"status": "healthy", "database": "connected"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/query")
def execute_query():
    query = request.args.get('query')
    if not query:
        return jsonify({"error": "Query parameter is required"}), 400
    
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(query)
        result = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify({"results": result})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/minio/list")
def list_minio_buckets():
    try:
        buckets = minio_client.list_buckets()
        return jsonify({"buckets": [bucket.name for bucket in buckets]})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/minio/read/<bucket>/<path:object>")
def read_minio_object(bucket, object):
    try:
        data = minio_client.get_object(bucket, object)
        return jsonify({"data": data.read().decode('utf-8')})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000) 