---
name: mosalla-firebase-functions
description: Workflow and rules for managing Firebase Cloud Functions in the Mosalla app. Use this skill whenever interacting with backend logic, index.js, or modifying cloud functions, so you remember to autonomously issue deployment commands.
---

# Mosalla Firebase Functions

This skill establishes strict operational boundaries whenever modifying backend Cloud Functions for the Mosalla application.

## System Environment
On this system (Mac), Node.js and Firebase tools are located in Homebrew's path. Always prepend the path to your commands:
- **PATH Adjustment**: `PATH=$PATH:/opt/homebrew/bin`

## Development Rules
1. **Always Syntax Check:** Before deploying, run a syntax check using Node to catch typos early:
   ```bash
   PATH=$PATH:/opt/homebrew/bin node -c functions/index.js
   ```
2. **Always Deploy After Editing:** If you (the AI) edit, patch, or rewrite *any* code located inside `/functions/index.js`, you MUST immediately execute the deployment:
   ```bash
   PATH=$PATH:/opt/homebrew/bin firebase deploy --only functions
   ```
3. **Path Dependency:** `index.js` acts on Firestore nodes. If the Flutter database schema changes (for example, switching from daily paths to monthly arrays like `prayer_months`), you MUST update the `functions/index.js` file appropriately to respect the architectural shifts.
4. **Trigger Visibility:** Because Cloud Functions are executed remotely, any logical errors or typos inside `index.js` will quietly crash the process without alerting the iOS/Android apps running locally. Pay strict attention to variables passed down via `.data()` and `Firestore` snapshot payloads.
