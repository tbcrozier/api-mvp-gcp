from flask import Flask, jsonify, request
from flask_restx import Api, Resource
from googleapiclient.discovery import build
from google.oauth2 import service_account


# If using Workload Identity you can omit service_account_file entirely
creds = service_account.Credentials.from_service_account_file(
    "/app/key.json",
    scopes=["https://www.googleapis.com/auth/cloud-platform"],
)
healthcare = build("healthcare", "v1", credentials=creds, cache_discovery=False)

app = Flask(__name__)
api = Api(app, title="MVP Healthcare API", version="1.0")

@app.route("/", methods=["GET"])
def index():
    return jsonify({"status": "ok"}), 200

@app.route("/patients", methods=["GET"])
def list_patients():
    parent = (
        "projects/vocal-spirit-372618/locations/us-central1/"
        "datasets/my-dataset/fhirStores/my-fhir-store"
    )
    req = (
        healthcare.projects()
        .locations()
        .datasets()
        .fhirStores()
        .fhir()
        .list(parent=parent, resourceType="Patient")
    )
    resp = req.execute()
    # resp.get("entry", []) is a list of FHIR bundles
    return jsonify(resp.get("entry", [])), 200

