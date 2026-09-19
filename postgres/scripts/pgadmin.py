#!/usr/bin/env python3
import os, json, re, sqlite3

BASE_DIR = "/Volumes/HDD/var/postgres"
PORT_RE = re.compile(r"^\s*port\s*=\s*(\d+)", re.IGNORECASE)
PGADMIN_DB = os.path.join(os.path.expanduser("~"), ".pgadmin", "pgadmin4.db")

if not os.path.exists(BASE_DIR):
    print(f"Error: Directory {BASE_DIR} not found")
    exit(1)

# 1. Parse postgresql.conf files
local_servers = {}
idx = 1

for name in os.listdir(BASE_DIR):
    conf_path = os.path.join(BASE_DIR, name, "postgresql.conf")
    if os.path.exists(conf_path):
        with open(conf_path, "r", encoding="utf-8") as f:
            ports = [int(PORT_RE.match(line).group(1)) for line in f if PORT_RE.match(line)]

        if ports:
            port = ports[0]
            local_servers[str(idx)] = {
                "Name": f"{name}:{port}",
                "Group": "LOCALHOST",
                "Host": "localhost",
                "Port": port,
                "MaintenanceDB": "postgres",
                "Username": "postgres"
            }
            idx += 1

if not local_servers:
    print("No active local servers found.")
    exit(0)

# 2. Update 'LOCALHOST' group in SQLite DB
try:
    conn = sqlite3.connect(PGADMIN_DB)
    cursor = conn.cursor()

    cursor.execute("SELECT id FROM servergroup WHERE name='LOCALHOST'")
    group = cursor.fetchone()

    if not group:
        cursor.execute("INSERT INTO servergroup (user_id, name) VALUES (1, 'LOCALHOST')")
        group_id = cursor.lastrowid
    else:
        group_id = group[0]

    cursor.execute("DELETE FROM server WHERE servergroup_id=?", (group_id,))

    for srv in local_servers.values():
        # Minimal universal set of columns present in all pgAdmin versions
        cursor.execute("""
            INSERT INTO server (
                user_id, servergroup_id, name, host, port, maintenance_db, username
            ) VALUES (1, ?, ?, 'localhost', ?, 'postgres', 'postgres')
        """, (group_id, srv["Name"], srv["Port"]))

    conn.commit()
    conn.close()

except sqlite3.OperationalError as e:
    if "locked" in str(e).lower():
        print("\n❌ Error: Database locked. Close pgAdmin (Cmd+Q) and rerun.")
        exit(1)
    else:
        raise e

print("restart pgAdmin")
