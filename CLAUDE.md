# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**blogbowl-core** is a Rails engine that contains the core business logic for [BlogBowl](https://github.com/dlysenko/BlogBowl), a multi-tenant blogging platform (blogs, changelogs, help centers). This engine is used as a Git submodule in the parent BlogBowl application at `submodules/core/`.

**Parent Application**: `https://github.com/BlogBowl/blogbowl-core`
**This Engine**: `https://github.com/BlogBowl/BlogBowl` (mounted as submodule at parent's `submodules/core/`)

The engine is loaded as a gem in the parent app via:
```ruby
# Parent's Gemfile
gem "core", path: "submodules/core"
```

## Engine Structure

```
blogbowl-core/
├── app/
│   ├── abilities/              # CanCanCan authorization
│   │   ├── author_ability.rb
│   │   ├── member_ability.rb
│   │   ├── post_ability.rb
│   │   └── workspace_ability.rb
│   ├── constraints/            # Route constraints
│   │   └── public_route_constraint.rb   # Multi-tenant routing by domain
│   ├── controllers/
│   │   ├── api/
│   │   │   ├── v1/             # Public REST API (token-authenticated)
│   │   │   │   ├── concerns/   # APIResponse, etc.
│   │   │   │   ├── base_controller.rb
│   │   │   │   ├── pages_controller.rb
│   │   │   │   ├── posts_controller.rb
│   │   │   │   ├── categories_controller.rb
│   │   │   │   ├── revisions_controller.rb
│   │   │   │   ├── images_controller.rb
│   │   │   │   ├── newsletters_controller.rb
│   │   │   │   ├── subscribers_controller.rb
│   │   │   │   └── emails_controller.rb
│   │   │   ├── internal/       # Internal API for React editor
│   │   │   │   ├── pages/      # Post/category/image management
│   │   │   │   ├── newsletters/
│   │   │   │   └── authors_controller.rb
│   │   │   └── public/
│   │   │       └── postmark_controller.rb  # Webhook handler
│   │   ├── admin/              # Admin panel controllers
│   │   ├── public/             # Public blog controllers
│   │   │   ├── pages_controller.rb
│   │   │   ├── posts_controller.rb
│   │   │   ├── categories_controller.rb
│   │   │   ├── authors_controller.rb
│   │   │   ├── archive_controller.rb
│   │   │   └── sitemap_controller.rb
│   │   ├── newsletters/        # Newsletter management
│   │   ├── settings/           # Workspace settings
│   │   └── sessions_controller.rb
│   ├── jobs/                   # Sidekiq background jobs
│   │   ├── publish_post_job.rb
│   │   ├── send_newsletter_job.rb
│   │   └── process_postmark_event_job.rb
│   ├── mailers/
│   │   ├── newsletter_test_mailer.rb
│   │   └── subscriber_mailer.rb
│   ├── models/                 # All ActiveRecord models
│   │   ├── workspace.rb        # Multi-tenant container
│   │   ├── page.rb             # Blog/changelog/help center
│   │   ├── post.rb             # Content with versioning
│   │   ├── post_revision.rb    # Version history
│   │   ├── category.rb
│   │   ├── author.rb
│   │   ├── member.rb
│   │   ├── newsletter.rb
│   │   ├── subscriber.rb
│   │   └── ...
│   ├── scrubbers/
│   │   └── custom_scrubber.rb  # HTML sanitization
│   └── views/                  # ERB templates
├── config/
│   ├── initializers/           # Engine-specific initializers
│   │   ├── cors.rb
│   │   ├── custom_parameterize.rb
│   │   ├── feature_guard.rb
│   │   ├── pagy.rb
│   │   ├── sidekiq.rb
│   │   └── truemail.rb
│   └── routes.rb               # All engine routes (merged with parent app)
├── lib/
│   ├── core.rb                 # Main engine file
│   ├── core/
│   │   ├── engine.rb           # Engine configuration
│   │   └── version.rb
│   ├── app_logger.rb
│   └── feature_guard.rb
└── test/                       # Minitest tests

```

## Key Components

### Multi-Tenant Architecture

The engine implements multi-tenancy through domain-based routing:

- **Admin routes** (e.g., `blogbowl.test` in dev): Workspace management, post editing, settings
- **Public routes** (custom domains): Blog pages served based on `Page.domain` lookup

The `PublicRouteConstraint` in `app/constraints/public_route_constraint.rb` handles this routing logic. Routes in `config/routes.rb` use constraints to determine which controller handles each request.

### API Endpoints

#### Public API (v1)
**Location**: `app/controllers/api/v1/`
**Authentication**: Bearer token via `APIToken` model
**Documentation**: Apipie DSL generates API docs at `/apidoc` in parent app

Key characteristics:
- **Base controller**: `API::V1::BaseController` authenticates and sets `@current_workspace`
- **Concerns**: Must be loaded via `require_relative` (Zeitwerk doesn't autoload custom paths)
- **Response format**: Collections use pagination envelope `{page, size, total, result}`
- **Pagination**: Pagy gem (default 10/page, max 100)

Available endpoints:
- Pages: `GET/POST/PATCH /api/v1/pages`
- Posts: `GET/POST/PATCH/DELETE /api/v1/posts`, `POST /api/v1/posts/:id/publish`
- Categories: `GET/POST/PATCH/DELETE /api/v1/pages/:page_id/categories`
- Revisions: `GET /api/v1/posts/:post_id/revisions`
- Newsletters: `GET/POST/PATCH /api/v1/newsletters`
- Subscribers: `GET/POST/PATCH/DELETE /api/v1/newsletters/:newsletter_id/subscribers`
- Emails: `GET/POST/PATCH/DELETE /api/v1/newsletters/:newsletter_id/emails`

#### Internal API
**Location**: `app/controllers/api/internal/`
**Authentication**: Session-based (admin users)
**Purpose**: Used by React editor in `submodules/editor/`

Key endpoints:
- `POST/PATCH /api/internal/pages/:page_id/posts` - Create/update from editor
- `POST /api/internal/pages/:page_id/posts/:id/publish` - Publish posts
- `GET/POST /api/internal/pages/:page_id/posts/:id/revisions` - Revision management
- `POST /api/internal/pages/:page_id/posts/:id/images` - Image uploads from editor

### Authorization

CanCanCan abilities in `app/abilities/`:
- `workspace_ability.rb` - Workspace-level access
- `member_ability.rb` - Member permissions within workspace
- `post_ability.rb` - Post owner/collaborator/viewer roles
- `author_ability.rb` - Author-specific permissions

### Background Jobs

Sidekiq jobs in `app/jobs/`:
- `PublishPostJob` - Scheduled post publishing
- `SendNewsletterJob` - Newsletter dispatch
- `ProcessPostmarkEventJob` - Email webhook handling (bounces, opens, clicks)

### Core Models

Multi-tenant structure:
```
Workspace → Members → Users
         ↓
        Page → Posts → PostRevisions
             ↓
            Categories
         ↓
        Newsletter → NewsletterEmails → Subscribers
         ↓
        Author (belongs to Member)
```

Model conventions:
- **Post statuses**: Enum with `draft: 0, published: 1, scheduled: 2`
- **to_param override**: `Page` model returns slug instead of ID for SEO URLs
- **Post versioning**: All edits create `PostRevision` records
- **Image processing**: Auto-converts uploads to WebP via `ConvertToWebp` concern

### Engine Configuration

`lib/core/engine.rb` configures autoload paths:
```ruby
module Core
  class Engine < ::Rails::Engine
    config.autoload_paths << "#{root}/app/abilities"
    config.autoload_paths << "#{root}/app/scrubbers"
  end
end
```

Initializers are loaded automatically by the parent app from `config/initializers/`.

## Working with the Engine

### Development Setup

Since this is a submodule, most development happens in the context of the parent application:

```bash
# Navigate to parent app
cd ../BlogBowl

# Update this submodule
git submodule update --remote submodules/core

# Start development server (runs parent + engine)
bin/dev
```

### Making Changes

1. **Make changes in this directory**
2. **Test in parent context**: The parent app includes this engine via Gemfile
3. **Commit changes**: This submodule has its own Git repository
4. **Update parent**: Parent repo tracks specific commit of submodule

#### Short Sync Workflow (engine → parent)
```bash
# In this repo
git checkout <branch>
git status
# ...edit, commit...
git push fork <branch>

# In parent repo (updates submodule pointer)
cd ../BlogBowl
# Fetch from local sibling clone or from a remote (either is fine)
git -C submodules/core fetch ../blogbowl-core   # local sibling clone linked to this submodule
git -C submodules/core fetch fork               # or: git -C submodules/core fetch upstream
git -C submodules/core checkout <core-commit-sha>
git add submodules/core
git commit -m "chore: bump blogbowl-core submodule"
git push fork <branch>
```
Notes:
- Parent repo stores only the submodule commit SHA.
- Remotes are named `fork` (dlysenko) and `upstream` (BlogBowl org).

### Testing

Tests are run from the **parent application**:

```bash
# From parent directory: ../BlogBowl

# Run all tests (includes engine tests)
bin/rails test

# Run core engine tests only
rake test:core_engine

# Run specific engine test
bin/rails test submodules/core/test/models/post_test.rb
```

Test database configuration is managed by the parent app.

## Important Technical Notes

### Zeitwerk Autoloading

- **API concerns**: Located at `app/controllers/api/v1/concerns/` - must be loaded via `require_relative` in base controllers
- **Custom paths**: `app/abilities/` and `app/scrubbers/` are added to autoload paths in engine.rb
- **API acronym**: Rails inflector has `inflect.acronym "API"`, so use `API::V1::` (not `Api::V1::`)

### Configuration from Parent App

The engine can access parent app configuration via `Rails.application`:

```ruby
# Example: Access parent's routes
Rails.application.routes.url_helpers.root_path

# Example: Access parent's config
Rails.application.config.some_setting
```

Environment variables (like `PAGES_BASE_DOMAIN`, `POSTMARK_*`, etc.) are loaded by the parent app and available throughout the engine.

### Parent App Integration Points

The parent app integrates this engine through:

1. **Gemfile**: `gem "core", path: "submodules/core"`
2. **Initializers**: Parent's `config/initializers/apipie.rb` references engine controllers:
   ```ruby
   config.api_controllers_matcher = ["#{Rails.root}/submodules/core/app/controllers/api/v1/**/*.rb"]
   ```
3. **Routes**: Engine routes are automatically merged into parent app's routes
4. **Assets**: Parent's asset pipeline includes engine assets
5. **React Editor**: Parent includes `submodules/editor/` which uses this engine's internal API

### Testing Conventions

- Use Minitest with fixtures in `test/fixtures/`
- WebMock for HTTP stubbing
- Set `ENV['PAGES_BASE_DOMAIN']` when testing page creation
- For models with custom `to_param`, explicitly use `id:` in tests:
  ```ruby
  api_v1_page_url(id: @page.id)  # Not api_v1_page_url(@page)
  ```

## Commands

### Development
```bash
# From parent app directory
bin/dev                # Start all services
bin/rails console      # Rails console (engine models available)
bin/rails routes       # View all routes (includes engine routes)
```

### Code Quality
```bash
# From parent app directory
bin/rubocop            # Lint (includes engine code)
bin/brakeman           # Security scan
```

### Database
```bash
# From parent app directory
bin/rails db:prepare   # Create, migrate, seed
RAILS_ENV=development bin/rails db:migrate
```

## Dependencies

Key gems (defined in `core.gemspec`):
- `rails` >= 8.0.2
- `cancancan` - Authorization
- `pagy` - Pagination
- `sidekiq` - Background jobs
- `truemail` - Email validation
- `postmark` - Email delivery
- `rack-attack` - Rate limiting
- `apipie-rails` - API documentation
- `nokogiri` - HTML parsing
- `active_storage_validations` - File validations

## Resources

- **Parent Repository**: https://github.com/dlysenko/BlogBowl
- **This Engine Repository**: https://github.com/BlogBowl/blogbowl-core
- **Parent CLAUDE.md**: `/Users/vika/projects/blogbowl/BlogBowl/CLAUDE.md`
