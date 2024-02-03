import sys
import http.server
import socketserver
import os
def run_server(serve_dir, port):
    class CustomRequestHandler(http.server.SimpleHTTPRequestHandler):
        def do_GET(self):
            requested_path = self.translate_path(self.path)
            if not self.is_path_allowed(requested_path):
                self.send_error(403, "Forbidden")
                return
            return http.server.SimpleHTTPRequestHandler.do_GET(self)

        def is_path_allowed(self, path):
            restricted_paths = ["math.txt", "restricted_directory"]
            for restricted_path in restricted_paths:
                if path.endswith(restricted_path) or path.startswith(restricted_path + "/"):
                    return False
            return True

    os.chdir(serve_dir)
    with socketserver.TCPServer(("", port), CustomRequestHandler) as httpd:
        print("Serving files from {} at http://localhost:{}".format(serve_dir, port))
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            httpd.server_close()

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python server.py <directory> <port>")
        sys.exit(1)

    serve_dir = sys.argv[1]
    port = int(sys.argv[2])
    run_server(serve_dir, port)
