#!/bin/bash

# Exit if any command fails
set -e

echo "🚀 Starting Firebase Dev Hosting Deployment..."

# Step 1: Clean & get packages
echo "🧹 Cleaning project..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

# Step 2: Build web
echo "🌐 Building Flutter Web..."
flutter build web

# Step 3: Deploy to Firebase Hosting (dev project)
echo "🔥 Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo "✅ Deployment completed successfully!"