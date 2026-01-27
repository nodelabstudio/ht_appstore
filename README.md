# Flutter App Builder

A comprehensive toolkit for building production-grade Flutter applications. This repository serves as both a **Knowledge Base** and a **Starter Kit**.

## 📚 What's Inside?

*   **`references/`**: Detailed documentation on best practices for Auth, Security, API, and Deployment.
*   **`assets/flutter-template/`**: A fully functional Clean Architecture starter project implementing the patterns from the references.

## 🚀 How to Use

### Option 1: As a Reference
Browse the `references/` directory to find copy-pasteable patterns for:
*   [Authentication](references/authentication.md)
*   [Secure Storage](references/security.md)
*   [API Integration](references/api-integration.md)
*   [App Store Deployment](references/deployment.md)

### Option 2: Start a New App
This repository includes a script to generate a fresh project from the template.

1.  **Clone this repository**:
    ```bash
    git clone https://github.com/yourusername/flutter-app-builder.git
    cd flutter-app-builder
    ```

2.  **Run the generator script**:
    ```bash
    # Usage: ./create_app.sh <new_project_name> <destination_path>
    ./create_app.sh my_amazing_app ../
    ```

3.  **Start coding**:
    ```bash
    cd ../my_amazing_app
    flutter run
    ```

## 🏗 Template Architecture
The starter template follows a scalable **Clean Architecture**:
```
lib/
├── config/        # Routes, Themes, Environment
├── core/          # Services (Auth, API), Utilities
├── features/      # Feature modules (Screens, Logic)
└── shared/        # Reusable Widgets, Models
```

## Contributing
Feel free to submit PRs to improve the reference documentation or the base template!
