# Documentation Index

Complete documentation for the Lapis API Template project.

## 📚 Documentation Structure

### 1. [Development](1.%20Development.md)
**Setup, workflow, and best practices**

Complete guide for developing with this Lapis API template:
- Prerequisites and initial setup
- Project structure overview
- Development workflow (hot-reload enabled)
- Database setup (SQLite by default)
- Production deployment with PostgreSQL
- Adding new features
- Common tasks and troubleshooting
- Performance tips

**Start here** if you're setting up the project for the first time.

---

### 2. [Api](2.%20Api.md)
**Complete API reference**

Documentation for all API endpoints:
- Response formats and status codes
- List all users (`GET /users`)
- Get user by ID (`GET /users/:id`)
- Create user (`POST /users`)
- Update user (`PUT /users/:id`)
- Delete user (`DELETE /users/:id`)
- Validation rules
- Testing tips with curl
- Future enhancements

**Use this** as reference when working with the API or creating new endpoints.

---

### 3. [Database](3.%20Database.md)
**Database configuration guide**

How to configure and switch between different database systems:
- SQLite (default for development)
- PostgreSQL (recommended for production)
- MySQL (alternative)
- Redis (for caching/sessions)
- Environment variables
- Production recommendations
- Troubleshooting
- Database migrations
- Performance tips

**Read this** when you need to configure databases or migrate to production.

---

### 4. [Testing](4.%20Testing.md)
**Testing with Busted framework**

Complete testing guide:
- Running tests (all, specific, verbose)
- Test structure and organization
- Writing tests (assertions, tables, setup/teardown)
- Testing HTTP APIs
- Advanced testing (mocking, spying, stubbing)
- Test coverage
- CI/CD integration
- Best practices and common patterns

**Consult this** when writing tests or setting up automated testing.

---

## 🚀 Quick Links

### Getting Started
1. Read [1. Development](1.%20Development.md) - Setup guide
2. Review [2. Api](2.%20Api.md) - Understand the API
3. Check [4. Testing](4.%20Testing.md) - Run tests

### Production Setup
1. Read [3. Database](3.%20Database.md) - Configure PostgreSQL
2. Read [1. Development](1.%20Development.md#production-setup-postgresql) - Deploy to production

### Adding Features
1. Read [1. Development](1.%20Development.md#adding-new-features) - How to add features
2. Read [2. Api](2.%20Api.md#contributing) - API conventions
3. Read [4. Testing](4.%20Testing.md#writing-tests) - Write tests

---

## 📖 Additional Resources

### Project Files
- [README.md](../README.md) - Project overview and quick start
- [project-requirements.md](../project-requirements.md) - User stories and requirements
- [.vscode/copilot-instructions.md](../.vscode/copilot-instructions.md) - Copilot guidelines

### External Documentation
- [Lapis Framework](https://leafo.net/lapis/) - Official Lapis documentation
- [OpenResty](https://openresty.org/) - OpenResty web platform
- [Lua 5.1 Reference](https://www.lua.org/manual/5.1/) - Lua language reference
- [Busted](https://olivinelabs.com/busted/) - Testing framework

---

## 🔄 Documentation Flow

```
┌─────────────────┐
│  README.md      │ ← Start here
│  (Quick Start)  │
└────────┬────────┘
         │
         ├──────────────────┬──────────────────┬──────────────────┐
         ↓                  ↓                  ↓                  ↓
┌────────────────┐  ┌───────────┐  ┌────────────┐  ┌──────────────┐
│ 1. Development │  │  2. Api   │  │ 3. Database│  │  4. Testing  │
│   (Setup)      │  │ (Reference│  │   (Config) │  │   (Tests)    │
└────────────────┘  └───────────┘  └────────────┘  └──────────────┘
         │                  │                  │                  │
         └──────────────────┴──────────────────┴──────────────────┘
                                    │
                          ┌─────────────────────┐
                          │ project-requirements│
                          │   (User Stories)    │
                          └─────────────────────┘
```

---

## 📝 Contributing to Documentation

When updating documentation:

1. **Follow the numbering**: Keep the `1. Name.md` format
2. **Add cross-references**: Link to related documents
3. **Update this index**: Reflect any structural changes
4. **Keep it current**: Update examples and code snippets
5. **Be consistent**: Follow existing formatting and style

### Markdown Style Guide

- Use `## Heading 2` for main sections
- Use `### Heading 3` for subsections
- Add blank lines around lists
- Specify language in code blocks: ` ```bash `, ` ```lua `
- Use **bold** for emphasis
- Use `code` for file names, commands, and code references

---

## 🆘 Need Help?

If you can't find what you're looking for:

1. Check the [README.md](../README.md) for a quick overview
2. Browse the documentation index above
3. Use search (Ctrl+F) in individual documents
4. Check the [project requirements](../project-requirements.md) for feature details
5. Review [Copilot instructions](../.vscode/copilot-instructions.md) for code patterns

---

**Last Updated**: October 19, 2025
