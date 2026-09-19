#!/usr/bin/env python
import json
import logging
import os
import requests

def main():
    # Get the current working directory where you ran the command
    cwd_path = os.getcwd().replace('\\', '/')
    path_parts = cwd_path.split('/')

    # Check if 'git' is part of your current folder structure
    if 'git' not in path_parts:
        raise ValueError(f"Invalid path structure: {cwd_path}. You must run this from inside a 'git' subdirectory structure.")

    git_idx = path_parts.index('git')

    try:
        OWNER = path_parts[git_idx + 1]
        NAME = path_parts[git_idx + 2]
    except IndexError:
        raise ValueError(f"Could not parse OWNER and NAME from current directory path: {cwd_path}")

    token = os.getenv("GITHUB_TOKEN")
    if not token or token.strip() == "":
        raise ValueError("CRITICAL: GITHUB_TOKEN environment variable is empty or not set!")

    headers = {
        "Authorization": f"Bearer {token.strip()}",
        "Accept": "application/vnd.github+json",
    }

    API_HOST = "api.github.com"

    # 1. Надежная проверка существования репозитория через API с авторизацией
    # Работает как для личных, так и для организационных репозиториев (публичных и приватных)
    api_check_url = f"https://{API_HOST}/repos/{OWNER}/{NAME}"
    check_res = requests.get(api_check_url, headers=headers)

    if check_res.status_code == 200:
        return
    elif check_res.status_code == 422:
        print(f"Repository '{OWNER}/{NAME}' already exists (API 422).")
        return

    # 2. Fetch Organizations (чтобы понять, куда создавать: в org или user)
    orgs_url = f"https://{API_HOST}/user/orgs"
    orgs_res = requests.get(orgs_url, headers=headers)
    orgs_res.raise_for_status()
    user_orgs = [org['login'].lower() for org in orgs_res.json()]

    if OWNER.lower() in user_orgs:
        url = f"https://{API_HOST}/orgs/{OWNER}/repos"
    else:
        url = f"https://{API_HOST}/user/repos"

    payload = {
        'name': NAME,
        'private': True
    }

    # 3. Create Repository
    r = requests.post(url, headers=headers, json=payload)

    # Обработка ответа
    if r.status_code == 422:
        print(f"Repository '{OWNER}/{NAME}' already exists (API 422 Unprocessable Entity).")
        return

    if r.status_code not in [200, 201]:
        try:
            print(json.dumps(r.json(), indent=2))
        except Exception as e:
            logging.exception(e)
        r.raise_for_status()
    else:
        print(f"Successfully created private repository '{OWNER}/{NAME}'.")

if __name__ == "__main__":
    main()
