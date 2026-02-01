import subprocess
import sys

def run_command(command):
    try:
        result = subprocess.run(command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {command}")
        print(e.stderr)
        return None

def get_remote_branches():
    output = run_command("git branch -r")
    if not output:
        return []
    branches = [b.strip() for b in output.split('\n')]
    # Filter out HEAD and main
    branches = [b for b in branches if "HEAD" not in b and "/main" not in b]
    return branches

def merge_branch(branch):
    print(f"Merging {branch}...")
    try:
        # Try standard merge first
        subprocess.run(f"git merge {branch} --no-edit", shell=True, check=True)
        print(f"Successfully merged {branch}")
        return True
    except subprocess.CalledProcessError:
        print(f"Standard merge failed for {branch}. Trying with --allow-unrelated-histories...")
        try:
            subprocess.run(f"git merge {branch} --no-edit --allow-unrelated-histories", shell=True, check=True)
            print(f"Successfully merged {branch} with --allow-unrelated-histories")
            return True
        except subprocess.CalledProcessError:
            print(f"Conflict merging {branch}")
            return False

def main():
    branches = get_remote_branches()
    print(f"Found {len(branches)} branches to merge.")

    for branch in branches:
        # Check if already merged
        # Skipping this check for now as git merge handles it gracefully (Already up to date)

        success = merge_branch(branch)
        if not success:
            print(f"Stopping due to conflict in {branch}. Please resolve manually and re-run.")
            sys.exit(1)

    print("All branches merged successfully!")

if __name__ == "__main__":
    main()
