# This script searches for URLs in a specified target (file or directory).
# Usage: ./url_search.sh <target>
# 
# Arguments:
#   <target> - The file or directory to search for URLs.
#
# If the target is a directory, it recursively searches for URLs in all files within the directory.
# If the target is a file, it searches for URLs within the file.
# 
# The script uses egrep with a regex pattern to match URLs and highlights them in the output.

# Check if target_dir argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <target>"
    exit 1
fi

target="$1"

# Check if target exists
if [ ! -e "$target" ]; then
    echo "Error: $target does not exist"
    exit 1
fi

# Perform the search
if [ -d "$target" ]; then
    # If target is a directory
    egrep --color -inr '\b((http|https):\/\/|www\.)[a-zA-Z0-9\-]+(\.[a-zA-Z]{2,})+(\/[^\s]*)?\b' "$target"
else
    # If target is a file
    egrep --color -in '\b((http|https):\/\/|www\.)[a-zA-Z0-9\-]+(\.[a-zA-Z]{2,})+(\/[^\s]*)?\b' "$target"
fi
