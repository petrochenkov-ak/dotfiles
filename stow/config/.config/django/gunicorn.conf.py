import os

workers = int(os.environ["GUNICORN_WORKERS_COUNT"])
threads = int(os.environ["GUNICORN_THREADS_COUNT"])
port = int(os.environ["GUNICORN_PORT"])
bind = f"0.0.0.0:{port}"
timeout = 10
