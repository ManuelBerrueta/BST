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
