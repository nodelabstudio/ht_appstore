#!/bin/bash

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <new_project_name> <destination_directory>"
    echo "Example: $0 my_cool_app ../projects"
    exit 1
fi

PROJECT_NAME=$1
DEST_DIR=$2
TEMPLATE_DIR="./assets/flutter-template"

# Ensure template exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Error: Template directory not found at $TEMPLATE_DIR"
    exit 1
fi

# Create destination if it doesn't exist
mkdir -p "$DEST_DIR"

# Full path for new project
NEW_PROJECT_PATH="$DEST_DIR/$PROJECT_NAME"

if [ -d "$NEW_PROJECT_PATH" ]; then
    echo "Error: Directory $NEW_PROJECT_PATH already exists."
    exit 1
fi

echo "🚀 Creating new Flutter app '$PROJECT_NAME'..."

# Copy template
cp -r "$TEMPLATE_DIR" "$NEW_PROJECT_PATH"

# Update pubspec.yaml name using sed (handles macOS/BSD sed differences)
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/name: flutter_template/name: $PROJECT_NAME/" "$NEW_PROJECT_PATH/pubspec.yaml"
    sed -i '' "s/description: \"A new Flutter project.\"/description: \"Created with Flutter App Builder\"/" "$NEW_PROJECT_PATH/pubspec.yaml"
else
    sed -i "s/name: flutter_template/name: $PROJECT_NAME/" "$NEW_PROJECT_PATH/pubspec.yaml"
    sed -i "s/description: \"A new Flutter project.\"/description: \"Created with Flutter App Builder\"/" "$NEW_PROJECT_PATH/pubspec.yaml"
fi

echo "📦 Installing dependencies..."
cd "$NEW_PROJECT_PATH"
flutter pub get

echo "✅ App created successfully at $NEW_PROJECT_PATH"
echo ""
echo "To get started:"
echo "  cd $NEW_PROJECT_PATH"
echo "  flutter run"
