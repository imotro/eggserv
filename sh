#!/bin/bash

# Set the directory to serve files from
SERVE_DIR="static"

# Set the port for the server
PORT=8000

# Set the restricted file paths
RESTRICTED_PATHS=("restricted_file.txt" "restricted_directory")

# Check if the directory exists
if [ ! -d "$SERVE_DIR" ]; then
  echo "Error: Directory $SERVE_DIR does not exist"
  exit 1
fi

# Change to the directory to serve files
cd "$SERVE_DIR" || exit

# Start the HTTP server function
start_server() {
  echo "Serving files from $SERVE_DIR at http://localhost:$PORT/"
  echo "Press Ctrl+C to stop the server"
  python3 -m http.server "$PORT" &>/dev/
}

# Function to check if a path is restricted
is_path_restricted() {
  local requested_path="$1"
  for restricted_path in "${RESTRICTED_PATHS[@]}"; do
    if [ "$requested_path" = "$restricted_path" ] || [[ "$requested_path" == "$restricted_path/"* ]]; then
      return 0
    fi
  done
  return 1
}

# Start the HTTP server
if ! start_server; then
  echo "Error: Failed to start server"
  exit 1
fi

# Main loop to handle requests
while true; do
  read -r request
  requested_path=$(echo "$request" | cut -d ' ' -f2)
  if is_path_restricted "$requested_path"; then
    echo "HTTP/1.1 403 Forbidden"
    echo "Content-Type: text/plain"
    echo
    echo "403 Forbidden: You don't have permission to access $requested_path"
  else
    echo "$request" | nc -q 0 -l -p "$PORT"
  fi
done
