"""
AarogyaVani Database Service — SQLite (local laptop, Cloudflare Tunnel)

This module provides the sole database interface. To migrate to Cloudflare D1
or PostgreSQL later, replace only the internals of DatabaseService — all routers
and services call through this abstraction.
"""

import aiosqlite
import json
from pathlib import Path
from app.core.config import settings

# --- Schema DDL ---
# FHIR-aligned field naming where possible.
TABLES_DDL = """
-- Patients
CREATE TABLE IF NOT EXISTS patients (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    age INTEGER,
    gender TEXT,
    phone TEXT,
    email TEXT,
    preferred_language TEXT DEFAULT 'en',
    abha_id TEXT,
    abha_address TEXT,
    abha_linked INTEGER DEFAULT 0,
    hospital_temp_id TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Sessions (encrypted temporary session per kiosk visit)
CREATE TABLE IF NOT EXISTS sessions (
    id TEXT PRIMARY KEY,
    patient_id TEXT NOT NULL,
    department_config TEXT NOT NULL DEFAULT 'ALLOPATHIC_OPD',
    language TEXT NOT NULL DEFAULT 'en',
    encrypted_token TEXT,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    expires_at TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(id)
);

-- Consent records (DPDP Act 2023)
CREATE TABLE IF NOT EXISTS consent_records (
    id TEXT PRIMARY KEY,
    patient_id TEXT NOT NULL,
    session_id TEXT,
    consent_type TEXT NOT NULL,
    granted INTEGER NOT NULL DEFAULT 0,
    consent_method TEXT DEFAULT 'digital',
    dpdp_compliant INTEGER NOT NULL DEFAULT 1,
    granted_at TEXT,
    revoked_at TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (session_id) REFERENCES sessions(id)
);

-- Conversations
CREATE TABLE IF NOT EXISTS conversations (
    id TEXT PRIMARY KEY,
    patient_id TEXT NOT NULL,
    session_id TEXT,
    department_config TEXT NOT NULL DEFAULT 'ALLOPATHIC_OPD',
    language TEXT NOT NULL DEFAULT 'en',
    status TEXT NOT NULL DEFAULT 'active',
    intake_state_json TEXT DEFAULT '{}',
    completeness_score REAL DEFAULT 0.0,
    red_flag_result_json TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (session_id) REFERENCES sessions(id)
);

-- Conversation messages
CREATE TABLE IF NOT EXISTS messages (
    id TEXT PRIMARY KEY,
    conversation_id TEXT NOT NULL,
    role TEXT NOT NULL,
    text TEXT NOT NULL,
    language TEXT DEFAULT 'en',
    is_voice INTEGER DEFAULT 0,
    attached_record_id TEXT,
    provenance_tag TEXT,
    timestamp TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (conversation_id) REFERENCES conversations(id)
);

-- Uploaded documents
CREATE TABLE IF NOT EXISTS documents (
    id TEXT PRIMARY KEY,
    patient_id TEXT NOT NULL,
    session_id TEXT,
    file_name TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size INTEGER,
    file_path TEXT,
    status TEXT NOT NULL DEFAULT 'uploading',
    extraction_json TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (session_id) REFERENCES sessions(id)
);

-- Clinical summaries (final confirmed output)
CREATE TABLE IF NOT EXISTS clinical_summaries (
    id TEXT PRIMARY KEY,
    conversation_id TEXT NOT NULL,
    patient_id TEXT NOT NULL,
    summary_json TEXT NOT NULL,
    fhir_bundle_json TEXT,
    status TEXT NOT NULL DEFAULT 'draft',
    confirmed_by_patient INTEGER DEFAULT 0,
    confirmed_by_physician INTEGER DEFAULT 0,
    physician_notes TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (conversation_id) REFERENCES conversations(id),
    FOREIGN KEY (patient_id) REFERENCES patients(id)
);

-- Visit history (for "same complaint" detection)
CREATE TABLE IF NOT EXISTS visit_history (
    id TEXT PRIMARY KEY,
    patient_id TEXT NOT NULL,
    conversation_id TEXT NOT NULL,
    chief_complaint TEXT,
    visit_date TEXT NOT NULL DEFAULT (datetime('now')),
    summary_id TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (conversation_id) REFERENCES conversations(id)
);
"""


class DatabaseService:
    """Async SQLite database service. Replace internals for Cloudflare D1 migration."""

    _db: aiosqlite.Connection | None = None

    @classmethod
    async def initialize(cls) -> None:
        """Open connection and create tables if they don't exist."""
        db_path = Path(settings.DATABASE_PATH)
        db_path.parent.mkdir(parents=True, exist_ok=True)

        cls._db = await aiosqlite.connect(str(db_path))
        cls._db.row_factory = aiosqlite.Row  # Return dict-like rows
        await cls._db.execute("PRAGMA journal_mode=WAL")  # Better concurrent reads
        await cls._db.execute("PRAGMA foreign_keys=ON")

        # Auto-create all tables
        for statement in TABLES_DDL.split(";"):
            stmt = statement.strip()
            if stmt:
                await cls._db.execute(stmt)
        await cls._db.commit()
        print(f"✅ Database initialized at {db_path}")

    @classmethod
    async def close(cls) -> None:
        """Close the database connection."""
        if cls._db:
            await cls._db.close()
            cls._db = None

    @classmethod
    def get_db(cls) -> aiosqlite.Connection:
        """Get the active database connection."""
        if cls._db is None:
            raise RuntimeError("Database not initialized. Call DatabaseService.initialize() first.")
        return cls._db

    # --- Convenience helpers ---

    @classmethod
    async def execute(cls, query: str, params: tuple = ()) -> aiosqlite.Cursor:
        db = cls.get_db()
        cursor = await db.execute(query, params)
        await db.commit()
        return cursor

    @classmethod
    async def fetch_one(cls, query: str, params: tuple = ()) -> dict | None:
        db = cls.get_db()
        cursor = await db.execute(query, params)
        row = await cursor.fetchone()
        if row is None:
            return None
        return dict(row)

    @classmethod
    async def fetch_all(cls, query: str, params: tuple = ()) -> list[dict]:
        db = cls.get_db()
        cursor = await db.execute(query, params)
        rows = await cursor.fetchall()
        return [dict(row) for row in rows]

    @classmethod
    async def insert(cls, table: str, data: dict) -> str:
        """Insert a row and return the id."""
        columns = ", ".join(data.keys())
        placeholders = ", ".join(["?"] * len(data))
        query = f"INSERT INTO {table} ({columns}) VALUES ({placeholders})"
        await cls.execute(query, tuple(data.values()))
        return data.get("id", "")

    @classmethod
    async def update(cls, table: str, record_id: str, data: dict) -> None:
        """Update a row by id."""
        set_clause = ", ".join([f"{k} = ?" for k in data.keys()])
        query = f"UPDATE {table} SET {set_clause} WHERE id = ?"
        await cls.execute(query, (*data.values(), record_id))
