-- Lab 03: write ALL FIVE complete CREATE TABLE statements here.
-- Read SCHEMA_CONTRACT.md for column names, types and integrity requirements.
-- Supply assets, subset_requests, download_attempts, artifacts, artifact_locations.
-- Include your chosen primary/foreign keys, uniqueness rules and CHECK constraints.
-- Do not change or recreate the existing five Lab 02 tables.
-- Run python check_lab03.py, then init your archive after checks pass.

CREATE TABLE assets (
    asset_id TEXT NOT NULL PRIMARY KEY,
    collection TEXT NOT NULL,
    item_id TEXT NOT NULL,
    asset_key TEXT NOT NULL CHECK (asset_key IN ('red', 'nir')),
    source_url TEXT NOT NULL,
    metadata_json TEXT NOT NULL,
    metadata_sha256 TEXT NOT NULL,
    created_at TEXT NOT NULL,
    UNIQUE (collection, item_id, asset_key, metadata_sha256),
    FOREIGN KEY (collection, item_id) REFERENCES scenes(collection, item_id)
);

CREATE TABLE subset_requests (
    subset_id TEXT NOT NULL PRIMARY KEY,
    asset_id TEXT NOT NULL,
    aoi_key TEXT NOT NULL,
    aoi_json TEXT NOT NULL,
    recipe_version TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('pending', 'ready', 'failed')),
    latest_artifact_id TEXT,
    updated_at TEXT NOT NULL,
    UNIQUE (asset_id, aoi_key, recipe_version),
    FOREIGN KEY (asset_id) REFERENCES assets(asset_id),
    FOREIGN KEY (latest_artifact_id, subset_id) REFERENCES artifacts(artifact_id, subset_id),
    CHECK (status <> 'ready' OR latest_artifact_id IS NOT NULL)
);

CREATE TABLE download_attempts (
    attempt_id TEXT NOT NULL PRIMARY KEY,
    subset_id TEXT NOT NULL,
    run_id TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('running', 'succeeded', 'reused', 'failed')),
    stage TEXT NOT NULL,
    started_at TEXT NOT NULL,
    finished_at TEXT,
    network_bytes INTEGER NOT NULL CHECK (network_bytes >= 0) DEFAULT 0,
    http_status INTEGER,
    artifact_id TEXT,
    error_code TEXT,
    error_message TEXT,
    FOREIGN KEY (subset_id) REFERENCES subset_requests(subset_id),
    FOREIGN KEY (run_id) REFERENCES runs(run_id),
    FOREIGN KEY (artifact_id, subset_id) REFERENCES artifacts(artifact_id, subset_id),
    CHECK (status <> 'running' OR finished_at IS NULL),
    CHECK (status = 'running' OR finished_at IS NOT NULL),
    CHECK (status NOT IN ('succeeded', 'reused') OR artifact_id IS NOT NULL)
);

CREATE TABLE artifacts (
    artifact_id TEXT NOT NULL PRIMARY KEY,
    subset_id TEXT NOT NULL,
    created_by_attempt_id TEXT NOT NULL,
    sha256 TEXT NOT NULL,
    size_bytes INTEGER NOT NULL CHECK (size_bytes > 0),
    raster_json TEXT NOT NULL,
    created_at TEXT NOT NULL,
    UNIQUE (subset_id, sha256),
    UNIQUE (artifact_id, subset_id),
    FOREIGN KEY (subset_id) REFERENCES subset_requests(subset_id)
);

CREATE TABLE artifact_locations (
    location_id TEXT NOT NULL PRIMARY KEY,
    artifact_id TEXT NOT NULL,
    local_path TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('available', 'missing', 'corrupt')),
    checked_at TEXT NOT NULL,
    FOREIGN KEY (artifact_id) REFERENCES artifacts(artifact_id)
);