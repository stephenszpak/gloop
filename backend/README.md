# Reality Anchor Backend

A Phoenix API backend for the Reality Anchor mobile app - a media literacy game for kids aged 4-8.

## 🚀 Quick Start

### Prerequisites

- Elixir 1.14+ and Erlang/OTP 25+
- PostgreSQL 14+
- Phoenix 1.7+

### Setup

1. **Install dependencies**
   ```bash
   mix deps.get
   ```

2. **Configure database**
   ```bash
   # Update config/dev.exs with your PostgreSQL credentials
   mix ecto.create
   mix ecto.migrate
   ```

3. **Seed sample data**
   ```bash
   mix run priv/repo/seeds.exs
   ```

4. **Start the server**
   ```bash
   mix phx.server
   ```

The API will be available at `http://localhost:4000/api/v1`

## 📖 API Documentation

### Authentication

All protected endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

### Core Endpoints

#### Authentication
- `POST /api/v1/auth/register` - Register parent account
- `POST /api/v1/auth/login` - Login with email/password
- `GET /api/v1/auth/me` - Get current user profile
- `POST /api/v1/auth/logout` - Logout (revoke token)

#### Child Profiles
- `GET /api/v1/child_profiles` - List children for current user
- `POST /api/v1/child_profiles` - Create new child profile
- `GET /api/v1/child_profiles/:id` - Get child details
- `PUT /api/v1/child_profiles/:id` - Update child profile
- `DELETE /api/v1/child_profiles/:id` - Delete child profile
- `GET /api/v1/child_profiles/:id/progress` - Get child's progress stats

#### Missions
- `GET /api/v1/missions/next?child_id=:id` - Get next mission for child
- `POST /api/v1/missions/:id/submit` - Submit mission answer
- `GET /api/v1/missions` - List all missions (optional)

#### Health Check
- `GET /api/v1/health` - API health status

### Request/Response Examples

#### User Registration
```bash
curl -X POST http://localhost:4000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "name": "Parent Name",
      "email": "parent@example.com",
      "password": "password123"
    }
  }'
```

Response:
```json
{
  "data": {
    "user": {
      "id": 1,
      "name": "Parent Name", 
      "email": "parent@example.com",
      "inserted_at": "2024-01-01T12:00:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### Get Next Mission
```bash
curl http://localhost:4000/api/v1/missions/next?child_id=1 \
  -H "Authorization: Bearer <token>"
```

Response:
```json
{
  "data": {
    "id": 1,
    "title": "Real Photo or AI Creation?",
    "type": "real_or_fake_image",
    "image_url": "https://example.com/image.jpg",
    "question_text": "Is this a real photo or created by AI?",
    "difficulty_level": 1,
    "tags": ["beginner", "nature"]
  }
}
```

#### Submit Mission Answer
```bash
curl -X POST http://localhost:4000/api/v1/missions/1/submit \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "child_id": 1,
    "selected_answer": true,
    "time_spent_ms": 5000
  }'
```

Response:
```json
{
  "data": {
    "submission": {
      "id": 1,
      "selected_answer": true,
      "is_correct": true,
      "time_spent_ms": 5000
    },
    "mission": {
      "id": 1,
      "correct_answer": true,
      "explanation": "✅ This is a real photo! You can tell because..."
    },
    "result": {
      "is_correct": true,
      "explanation": "✅ This is a real photo! You can tell because..."
    }
  }
}
```

## 🏗️ Architecture

### Database Schema

- **users** - Parent accounts (email, password, name)
- **child_profiles** - Children belonging to parents (name, avatar, birth_year)  
- **missions** - Game content (image_url, question, correct_answer, explanation)
- **submissions** - Child answers to missions (selected_answer, is_correct, time_spent)

### Key Features

✅ **JWT Authentication** - Secure token-based auth using Guardian  
✅ **Child Progress Tracking** - Accuracy rates, streaks, daily progress  
✅ **Adaptive Difficulty** - Missions adjust based on child age and performance  
✅ **Mission Types** - Images, stories, videos, news verification  
✅ **CORS Support** - Configured for mobile app access  
✅ **Comprehensive Tests** - Context and controller test coverage  
✅ **Admin Dashboard** - LiveView interface for monitoring (TODO: Add auth)  

## 🔧 Development

### Generate Sample Missions
```bash
# Generate 10 random missions
mix reality_anchor.gen.missions --count 10

# Generate specific type and difficulty  
mix reality_anchor.gen.missions --type real_or_fake_image --difficulty 2

# Clear existing missions first
mix reality_anchor.gen.missions --clear --count 20
```

### Database Operations
```bash
# Reset database
mix ecto.reset

# Create new migration
mix ecto.gen.migration add_new_field

# Run migrations
mix ecto.migrate
```

### Testing
```bash
# Run all tests
mix test

# Run with coverage
mix test --cover

# Run specific test file
mix test test/reality_anchor/accounts_test.exs
```

### Admin Dashboard
Visit `http://localhost:4000/admin` to view the admin dashboard (development only).

TODO: Add proper admin authentication before production deployment.

## 🚀 Production Deployment

### Environment Variables
```bash
# Required
DATABASE_URL=ecto://user:pass@host/database
SECRET_KEY_BASE=<64-char-secret>
GUARDIAN_SECRET_KEY=<jwt-secret>

# Optional
PHX_HOST=yourdomain.com
PORT=4000
POOL_SIZE=10
```

### Security Checklist

- [ ] Update CORS origins to your mobile app domains
- [ ] Set strong Guardian secret key
- [ ] Configure rate limiting (TODO: Add Hammer or similar)
- [ ] Add admin authentication for dashboard
- [ ] Set up SSL/TLS certificates
- [ ] Configure proper error monitoring (Sentry, Honeybadger, etc.)

## 🔮 Future Integrations

### AI Content Generation (TODO)
The `RealityAnchor.AI` module provides placeholders for:

- **OpenAI DALL-E** - Generate realistic vs obviously-fake images
- **OpenAI GPT-4** - Create age-appropriate questions and explanations
- **Content Moderation** - Ensure all content is child-safe
- **Adaptive Learning** - Generate missions based on child's progress

To integrate:
1. Add OpenAI API key to config
2. Implement API calls in `lib/reality_anchor/ai.ex`
3. Add content safety validation
4. Create background job processing

### Analytics & Monitoring
- Child engagement metrics
- Mission difficulty optimization
- Parent dashboard insights
- A/B testing for educational content

## 📄 License

This project is licensed under the MIT License.

---

**Demo Login**: `parent@example.com` / `password123`  
**API Base URL**: `http://localhost:4000/api/v1`  
**Admin Dashboard**: `http://localhost:4000/admin` (dev only)