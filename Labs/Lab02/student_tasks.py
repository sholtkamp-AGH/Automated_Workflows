"""Repair these three functions. The service and command parser are supplied."""
from datetime import datetime, timezone
from pathlib import Path
from lab01_service import utc_parse, utc_text

def resolve_paths(config, config_path):
    """Exercise 1: this works only when the terminal is in the expected folder.
    Make the configuration file's parent the anchor for all three paths.
    Preserve absolute paths. Do not create files here or change the working directory.
    """
    base_dir = Path(config_path).parent
    resolved = {}
    
    for key in ('database', 'preview_directory', 'log_file'):
        path_val = Path(config[key])
        if path_val.is_absolute():
            resolved[key] = path_val.resolve()
        else:
            resolved[key] = (base_dir / path_val).resolve()
            
    return resolved

def choose_until(explicit_until=None, clock=None):
    """Exercise 2: this copied demonstration end never discovers fresh scenes.
    Preserve an explicit --until (normalizing it to UTC); otherwise capture the
    current aware UTC clock once. clock is supplied only by the checks.
    Reject timestamps without a timezone instead of assuming local time.
    """
    if explicit_until is not None:
        if isinstance(explicit_until, str):
            parsed_str = explicit_until.replace('Z', '+00:00')
            try:
                dt = datetime.fromisoformat(parsed_str)
            except Exception as e:
                raise ValueError(f"Invalid timestamp format: {explicit_until}") from e
        elif isinstance(explicit_until, datetime):
            dt = explicit_until
        else:
            raise TypeError("explicit_until must be a string or datetime object")

        if dt.tzinfo is None:
            raise ValueError("Timestamps without a timezone are rejected. Please provide a timezone-aware timestamp.")
        
        dt_utc = dt.astimezone(timezone.utc)
    else:
        if clock is not None:
            now = clock() if callable(clock) else clock
        else:
            now = datetime.now(timezone.utc)
        
        if not isinstance(now, datetime):
            raise TypeError("Clock must return or be a datetime object")
        
        if now.tzinfo is None:
            raise ValueError("Clock timestamp must be timezone-aware.")
            
        dt_utc = now.astimezone(timezone.utc)

    return dt_utc.isoformat().replace('+00:00', 'Z')

def execute_job(job, logger):
    """Exercise 3: the terminal currently claims success after a failed job.
    On success return (0, the job result). On failure log the exception and return
    (1, a dictionary with status='failed' and an informative error string).
    Keep the exception handler, but report its actual outcome.
    """
    try:
        return 0, job()
    except Exception as e:
        logger.exception("Job execution failed")
        return 1, {'status': 'failed', 'error': str(e)}
