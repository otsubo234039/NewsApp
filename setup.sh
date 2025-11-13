#!/bin/bash

# NewsAPP Setup Script
# This script helps you set up both the frontend and backend

set -e

echo "🚀 NewsAPP Setup Script"
echo "======================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for required tools
echo "Checking prerequisites..."

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js 20+${NC}"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm is not installed. Please install npm${NC}"
    exit 1
fi

if ! command -v ruby &> /dev/null; then
    echo -e "${RED}❌ Ruby is not installed. Please install Ruby 3.2+${NC}"
    exit 1
fi

if ! command -v bundle &> /dev/null; then
    echo -e "${RED}❌ Bundler is not installed. Please run: gem install bundler${NC}"
    exit 1
fi

if ! command -v psql &> /dev/null; then
    echo -e "${YELLOW}⚠️  PostgreSQL CLI not found. Make sure PostgreSQL is installed and running.${NC}"
fi

echo -e "${GREEN}✅ All prerequisites found!${NC}"
echo ""

# Setup Backend
echo "📦 Setting up Backend..."
cd backend

if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo -e "${YELLOW}⚠️  Please edit backend/.env and add your NewsAPI key${NC}"
else
    echo ".env file already exists"
fi

echo "Installing Ruby dependencies..."
bundle install --path vendor/bundle

echo "Setting up database..."
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed

echo -e "${GREEN}✅ Backend setup complete!${NC}"
echo ""

# Setup Frontend
echo "📦 Setting up Frontend..."
cd ../frontend

if [ ! -f .env.local ]; then
    echo "Creating .env.local file from template..."
    cp .env.local.example .env.local
else
    echo ".env.local file already exists"
fi

echo "Installing Node dependencies..."
npm install

echo -e "${GREEN}✅ Frontend setup complete!${NC}"
echo ""

# Final instructions
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "Next steps:"
echo "1. Get your free NewsAPI key from: https://newsapi.org/"
echo "2. Add it to backend/.env file: NEWS_API_KEY=your_key_here"
echo ""
echo "To start the application:"
echo ""
echo "Terminal 1 (Backend):"
echo "  cd backend"
echo "  bundle exec rails server -p 3001"
echo ""
echo "Terminal 2 (Frontend):"
echo "  cd frontend"
echo "  npm run dev"
echo ""
echo "Then open http://localhost:3000 in your browser"
echo ""
