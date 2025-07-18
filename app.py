from flask import Flask, jsonify, request
from flask_restx import Api, Resource
import google.auth
from googleapiclient.discovery import build

# Use Application Default Credentials (Workload Identity on GKE)
creds, _ = google.auth.default(
    scopes=["https://www.googleapis.com/auth/cloud-platform"]
)

# Build the Cloud Healthcare API client
healthcare = build("healthcare", "v1", credentials=creds, cache_discovery=False)

app = Flask(__name__)
api = Api(
    app,
    title="MVP Healthcare API",
    version="1.0",
    description="Custom layer on Cloud Healthcare FHIR store",
)

@app.route("/", methods=["GET"])
def index():
    return jsonify({"status": "ok"}), 200

@app.route("/patients", methods=["GET"])
def list_patients():
    # Replace these with your actual dataset & FHIR store names as needed
    parent = (
        "projects/vocal-spirit-372618/locations/us-central1/"
        "datasets/my-dataset/fhirStores/my-fhir-store"
    )

    request = (
        healthcare.projects()
        .locations()
        .datasets()
        .fhirStores()
        .fhir()
        .list(parent=parent, resourceType="Patient")
    )
    resp = request.execute()
    return jsonify(resp.get("entry", [])), 200

if __name__ == "__main__":
    # For local testing only—GKE uses Gunicorn in production
    app.run(host="0.0.0.0", port=8080)
