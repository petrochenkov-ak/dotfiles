import json
import os
from pathlib import Path
import subprocess
import sys
import urllib.request
import urllib.error

API_KEY = os.environ.get("OPENAI_API_KEY")
BASE_URL = os.environ.get("OPENAI_API_BASE")

OPENAI_MODEL = "gpt-5.6-luna"

PROMPT_PATH = Path.home() / ".config/prompts/git/commit_message_gen.md"
SYSTEM_PROMPT = PROMPT_PATH.read_text(encoding="utf-8")

if not API_KEY or not BASE_URL:
    sys.exit("Error: Environment variables OPENAI_API_KEY or OPENAI_API_BASE are not set.")

def get_git_diff():
    result = subprocess.run(
        ["git", "diff", "--staged"],
        capture_output=True, text=True, check=True
    )
    return result.stdout.strip()

def generate_commit_message(diff_text):
    url = f"{BASE_URL.rstrip('/')}/chat/completions"
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    data = {
        "model": OPENAI_MODEL,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": f"Here is the git diff:\n\n{diff_text}"}
        ],
        "temperature": 0.1
    }

    req = urllib.request.Request(
        url, data=json.dumps(data).encode("utf-8"), headers=headers, method="POST"
    )

    try:
        # Ставим таймаут поменьше (15 сек), чтобы скрипт не висел бесконечно, если сервак тупит
        with urllib.request.urlopen(req, timeout=42) as response:
            res_body = json.loads(response.read().decode("utf-8"))
            # ИСПРАВЛЕНО: добавлен [0] для корректного парсинга ответа API
            return res_body["choices"][0]["message"]["content"].strip()
    except urllib.error.HTTPError as e:
        sys.exit(f"API Error ({e.code}): {e.read().decode('utf-8', errors='ignore')}")
    except urllib.error.URLError as e:
        sys.exit(f"Network Timeout/Error: {e.reason}. Try running again or check model availability.")
    except (KeyError, IndexError):
        sys.exit("API Error: Unexpected JSON structure from server.")

if __name__ == "__main__":
    git_diff = get_git_diff()
    if not git_diff:
        sys.exit("Error: No staged files found. Run 'git add' first.")

    commit_message = generate_commit_message(git_diff)
    print(commit_message)
