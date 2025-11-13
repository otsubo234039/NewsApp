# NewsAPP Architecture

## Overview

NewsAPP is a full-stack web application that provides personalized news feeds based on user-selected interest tags. The application consists of a React/Next.js frontend and a Ruby on Rails API backend, with NewsAPI as the external news data source.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         User Browser                         │
│                     http://localhost:3000                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/REST
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Next.js Frontend (Port 3000)              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Components:                                            │ │
│  │  • TagSelector - Manages user interest tags            │ │
│  │  • NewsFeed - Displays filtered news articles          │ │
│  │  • NewsCard - Individual article display               │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  API Client (lib/api.ts):                              │ │
│  │  • getTags(), getUserTags(), addUserTag(), etc.        │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ REST API Calls
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                Rails API Backend (Port 3001)                 │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Controllers:                                           │ │
│  │  • TagsController - List available tags                │ │
│  │  • UserTagsController - Manage user preferences        │ │
│  │  • NewsController - Fetch filtered news                │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Models:                                                │ │
│  │  • Tag - Interest categories                           │ │
│  │  • UserTag - User-to-tag associations                  │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                   │                         │
                   │                         │ HTTP
                   │                         ▼
                   │           ┌──────────────────────────┐
                   │           │   NewsAPI.org            │
                   │           │   (External Service)     │
                   │           └──────────────────────────┘
                   │
                   │ SQL
                   ▼
        ┌──────────────────────┐
        │   PostgreSQL         │
        │   Database           │
        └──────────────────────┘
```

## Database Schema

### Tables

#### tags
- `id` (integer, primary key)
- `name` (string, unique)
- `created_at` (timestamp)
- `updated_at` (timestamp)

#### user_tags
- `id` (integer, primary key)
- `user_id` (integer)
- `tag_id` (integer, foreign key → tags.id)
- `created_at` (timestamp)
- `updated_at` (timestamp)
- Unique index on `(user_id, tag_id)`

## API Endpoints

### GET /api/v1/tags
Returns all available interest tags.

**Response:**
```json
[
  { "id": 1, "name": "technology" },
  { "id": 2, "name": "business" }
]
```

### GET /api/v1/user_tags?user_id=1
Returns user's selected tags.

**Response:**
```json
[
  {
    "id": 1,
    "user_id": 1,
    "tag_id": 1,
    "tag": { "id": 1, "name": "technology" }
  }
]
```

### POST /api/v1/user_tags
Adds a tag to user preferences.

**Request Body:**
```json
{
  "user_id": 1,
  "tag_id": 1
}
```

**Response:** 201 Created with created user_tag object

### DELETE /api/v1/user_tags/:id
Removes a tag from user preferences.

**Response:** 200 OK with success message

### GET /api/v1/news?user_id=1
Fetches news articles based on user's tag preferences.

**Response:**
```json
{
  "articles": [
    {
      "title": "Article Title",
      "description": "Article description",
      "url": "https://...",
      "urlToImage": "https://...",
      "publishedAt": "2025-11-13T...",
      "source": { "name": "Source Name" },
      "author": "Author Name"
    }
  ],
  "totalResults": 20
}
```

## Component Flow

### User Interaction Flow

1. **Initial Load**
   - Frontend loads and fetches available tags from `/api/v1/tags`
   - Frontend fetches user's selected tags from `/api/v1/user_tags`
   - Frontend displays both lists

2. **Tag Selection**
   - User clicks on a tag to select/deselect
   - Frontend sends POST or DELETE request to `/api/v1/user_tags`
   - UI updates immediately to reflect the change

3. **News Display**
   - NewsFeed component fetches news from `/api/v1/news`
   - Backend queries NewsAPI with user's tag keywords
   - Backend returns filtered articles
   - Frontend displays articles in a responsive grid

4. **Refresh**
   - User clicks refresh button
   - Frontend re-fetches news from backend
   - Latest articles are displayed

## Data Flow

```
User Action → Frontend Component → API Client → Backend Controller 
                                                       ↓
                                                  Database Query
                                                       ↓
User sees update ← Frontend Updates ← JSON Response ← Controller Response
```

## Technology Choices

### Frontend: Next.js + TypeScript
- **Next.js 16**: Modern React framework with App Router
- **TypeScript**: Type safety for API calls and components
- **Tailwind CSS**: Utility-first styling for rapid UI development
- **Server Components**: For optimal performance

### Backend: Rails API
- **Rails 8.1**: Mature, convention-over-configuration framework
- **API-only mode**: Lightweight, focused on JSON responses
- **PostgreSQL**: Reliable, feature-rich database
- **Rack-CORS**: Easy cross-origin request handling

### External Services
- **NewsAPI**: Comprehensive news aggregation from thousands of sources
- Free tier: 100 requests/day, 1000 requests/month

## Security Considerations

1. **No Authentication (Demo)**: Currently uses default user_id=1
2. **CORS**: Restricted to localhost in development
3. **Input Validation**: Type coercion and validation on all inputs
4. **Error Handling**: Errors logged but not exposed to users
5. **Environment Variables**: Sensitive data (API keys) in .env files

## Scalability Considerations

For production deployment:

1. **Caching**: Implement Redis for news article caching (NewsAPI rate limits)
2. **Background Jobs**: Use Sidekiq for async NewsAPI requests
3. **CDN**: Serve frontend static assets via CDN
4. **Database**: Connection pooling, read replicas
5. **Rate Limiting**: Implement per-user rate limits
6. **Authentication**: Add JWT or session-based auth
7. **Horizontal Scaling**: Multiple backend instances behind load balancer

## Development Workflow

1. **Backend Development**
   ```bash
   cd backend
   bundle exec rails console    # Interactive console
   bundle exec rails db:migrate # Run migrations
   bundle exec rails test       # Run tests
   ```

2. **Frontend Development**
   ```bash
   cd frontend
   npm run dev     # Development server with hot reload
   npm run build   # Production build
   npm run lint    # Lint code
   ```

3. **Full Stack**
   - Run backend on port 3001
   - Run frontend on port 3000
   - Frontend proxies API calls to backend via CORS

## Deployment Options

1. **Traditional**: Deploy Rails on Heroku/Railway, Next.js on Vercel
2. **Docker**: Use provided docker-compose.yml for containerized deployment
3. **Platform as a Service**: AWS, Google Cloud, Azure with managed PostgreSQL

## Future Enhancements

- User authentication and profiles
- Save favorite articles
- Share articles on social media
- Email digests of daily news
- Mobile app (React Native)
- Article bookmarking and reading history
- Multi-language support
- Custom tag creation
- News source filtering
- Advanced search functionality
