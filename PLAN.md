## Project Progress Checklist

- [ ] **Milestone 1: Project Setup & Core Architecture**
- [ ] **Milestone 2: Transaction Management**
- [ ] **Milestone 3: Budgeting**
- [ ] **Milestone 4: Dashboard & Reporting**
- [ ] **Milestone 5: Finalization & Polish**

# Project Plan: Finance Tracker

This document outlines the development plan for building the Finance Tracker application. The plan is broken down into milestones, each with a set of specific tasks. This plan is based on the requirements in the `PRD.md` file.

## Milestone 1: Project Setup & Core Architecture

**Goal:** Establish the foundation of the project, including the file structure, core dependencies, and database setup.

*   **Task 1.1:** Initialize the Flutter project and configure it for desktop development (Windows, macOS, Linux).
    *   **Verification:** Run `flutter run` on a desktop target to ensure the default application builds and launches successfully.
*   **Task 1.2:** Add initial dependencies to `pubspec.yaml`: `flutter_riverpod`, `drift` (for the database), `path_provider`, `intl`, and `fl_chart`.
    *   **Verification:** Run `flutter pub get` and then `flutter run` to confirm that the project still builds and runs without errors.
*   **Task 1.3:** Create the project directory structure as defined in `GEMINI.md`.
    *   **Verification:** Check that the directory structure is in place and run `flutter run`.
*   **Task 1.4:** Implement the main application shell with a basic desktop layout (e.g., a side navigation rail and a main content area).
    *   **Verification:** Run `flutter run` to see the new layout and navigate between placeholder pages.
*   **Task 1.5:** Set up the `drift` database with initial tables for `transactions` and `categories`.
    *   **Verification:** Write a unit test to open the database and verify table creation. Run the app to ensure it doesn't crash.
*   **Task 1.6:** Implement the Riverpod providers for accessing the database.
    *   **Verification:** Write a unit test to ensure providers can be read and can interact with the database. Run the app.

## Milestone 2: Transaction Management

**Goal:** Implement the core functionality for managing user transactions.

*   **Task 2.1:** Build the UI form for adding and editing transactions (income and expenses).
    *   **Verification:** Run the app and open the form. Test the UI elements.
*   **Task 2.2:** Implement the logic to save, update, and delete transactions in the database.
    *   **Verification:** Write unit tests for the logic. Run the app and manually add/edit/delete a transaction to confirm it works.
*   **Task 2.3:** Create the UI to display a list of all transactions.
    *   **Verification:** Run the app and confirm that transactions added in the previous step are displayed correctly.
*   **Task 2.4:** Implement filtering (by date, category, type) and search functionality for the transactions list.
    *   **Verification:** Manually test the filtering and search UI in the running application.
*   **Task 2.5:** Add the functionality to create, edit, and delete custom categories.
    *   **Verification:** Manually test the category management UI. Ensure new categories can be used in the transaction form.
*   **Task 2.6:** Implement the logic for handling recurring income.
    *   **Verification:** Write unit tests for the recurrence logic. Manually set an income as recurring and check that it is added automatically after the specified period.

## Milestone 3: Budgeting

**Goal:** Enable users to create and track budgets.

*   **Task 3.1:** Create the database table and models for `budgets`.
    *   **Verification:** Update the database test to verify the new table. Run the app.
*   **Task 3.2:** Build the UI for creating and viewing monthly budgets for different categories.
    *   **Verification:** Manually create a budget using the new UI.
*   **Task 3.3:** Implement the business logic to track spending against the defined budgets.
    *   **Verification:** Write unit tests for the budget tracking logic. Manually check the UI for correctness.
*   **Task 3.4:** Add visual indicators in the UI to show budget progress and warnings.
    *   **Verification:** Manually exceed a budget and confirm the visual warning appears.

## Milestone 4: Dashboard & Reporting

**Goal:** Provide users with visual insights into their financial data.

*   **Task 4.1:** Design and build the main dashboard UI to display a summary of the user's financial status.
    *   **Verification:** Run the app and check the dashboard with mock data.
*   **Task 4.2:** Create the reporting screen where users can see their financial data visualized.
    *   **Verification:** Navigate to the reporting screen in the running app.
*   **Task 4.3:** Integrate `fl_chart` to create the specified reports (pie, bar, line).
    *   **Verification:** Manually inspect each chart in the running app to ensure it displays correctly with test data.
*   **Task 4.4:** Implement the specific report for comparing spending in a single category across multiple months.
    *   **Verification:** Test the comparison report with data spanning several months.

## Milestone 5: Finalization & Polish

**Goal:** Refine the application and prepare it for an initial release.

*   **Task 5.1:** Implement the first-time user onboarding process, including currency selection.
    *   **Verification:** Clear app data and run the app to test the onboarding flow from the beginning.
*   **Task 5.2:** Conduct a full UI/UX review and apply polish to all screens.
    *   **Verification:** Manually navigate through the entire application, checking for visual inconsistencies or usability issues.
*   **Task 5.3:** Write additional unit and widget tests to improve code coverage.
    *   **Verification:** Run `flutter test` and ensure all tests pass.
*   **Task 5.4:** Perform code cleanup, refactoring, and add documentation.
    *   **Verification:** Run `flutter analyze` to check for issues. Run the app to ensure no regressions were introduced.
*   **Task 5.5:** Build and test the final desktop application executables.
    *   **Verification:** Install and run the application on each target desktop platform (Windows, macOS, Linux).