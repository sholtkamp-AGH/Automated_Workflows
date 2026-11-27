-- Write your own diagnostic SQL for the five new tables.
SELECT al.artifact_id, al.local_path, a.sha256, al.status, a.size_bytes, da.network_bytes
FROM artifact_locations AS al
JOIN artifacts AS a ON a.artifact_id = al.artifact_id
JOIN download_attempts AS da ON da.artifact_id = al.artifact_id
WHERE da.status != "reused"

-- One worked example follows. Add your case queries below it.
SELECT r.run_id,r.command,a.item_id,a.asset_key,s.aoi_key,d.status,d.stage,
       d.network_bytes,d.http_status,d.error_code,d.error_message
FROM download_attempts d JOIN runs r ON r.run_id=d.run_id
JOIN subset_requests s ON s.subset_id=d.subset_id
JOIN assets a ON a.asset_id=s.asset_id
ORDER BY d.started_at,d.attempt_id;

-- Case A: show failed band, partial success and the later recovery history.
SELECT da.run_id, a.asset_key, da.status, da.stage, da.network_bytes, da.artifact_id
FROM download_attempts AS da
JOIN subset_requests AS sr ON sr.subset_id = da.subset_id
JOIN assets AS a ON a.asset_id = sr.asset_id

-- Case B: show successful historical acquisition but current missing/corrupt location.
SELECT al.artifact_id, a.asset_key, da.started_at, da.status, al.local_path, ar.size_bytes, al.status, ar.sha256
FROM artifact_locations AS al
JOIN download_attempts AS da ON da.artifact_id = al.artifact_id
JOIN subset_requests AS sr ON sr.subset_id = da.subset_id
JOIN assets AS a ON a.asset_id = sr.asset_id
JOIN artifacts AS ar ON ar.artifact_id = al.artifact_id
ORDER BY da.started_at

-- AOI identity: show one source band with separate requests for two AOIs.
SELECT sr.subset_id, sr.asset_id, sr.latest_artifact_id
FROM subset_requests AS sr
