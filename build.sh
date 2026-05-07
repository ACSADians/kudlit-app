#!/bin/bash
set -e

git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Write .env from CI environment variables so flutter_dotenv can load it.
# All three variables must be set as secrets in the CI environment.
cat > .env <<EOF
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
GEMINI_API_KEY=${GEMINI_API_KEY}
HUGGINGFACE_TOKEN=${HUGGINGFACE_TOKEN:-}
EOF

echo "=== .env contents ==="
cat .env
echo "====================="

flutter config --enable-web
flutter pub get
flutter build web --release
