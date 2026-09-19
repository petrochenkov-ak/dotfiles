import subprocess
import sys

def is_initial_commit() -> bool:
    try:
        subprocess.run(["git", "rev-parse", "--verify", "HEAD"],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        return False
    except subprocess.CalledProcessError:
        return True

def main():
    if is_initial_commit():
        print("feat: initial commit")
        return

    files_out = subprocess.check_output(
        ["git", "diff", "--cached", "--name-only"], text=True
    ).strip()

    if not files_out:
        return

    files = files_out.split("\n")

    stat_out = subprocess.check_output(
        ["git", "diff", "--cached", "--shortstat"], text=True
    ).strip()
    lines_changed = 0
    if stat_out:
        for part in stat_out.split(","):
            if "insertion" in part or "deletion" in part:
                lines_changed += int(''.join(filter(str.isdigit, part)))

    if lines_changed <= 1:
        print("chore: minor update")
        return

    if len(files) >= 5:
        subprocess.run([sys.executable, "-m", "git_commit_message_files_summary"], check=True)
    else:
        subprocess.run([sys.executable, "-m", "git_commit_message_ai_gen_print"], check=True)


if __name__ == "__main__":
    main()
