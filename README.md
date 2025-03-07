# Expense Tracker App

A modern, intuitive expense tracking application built with Flutter that helps users manage their personal finances effectively. This app empowers users to take control of their spending habits, set budgets, and make informed financial decisions.

## Overview

Expense Tracker is designed with simplicity and functionality in mind. It provides a clean, user-friendly interface for tracking daily expenses while offering powerful analytics to understand spending patterns. Built with Flutter, it ensures a consistent experience across iOS and Android platforms.

## Features

- 💰 **Comprehensive Expense Management**:
  - Add, edit, and delete expenses with ease
  - Add notes and receipts to each transaction
  - Bulk edit or delete capabilities
- 📊 **Smart Category Organization**:
  - Pre-defined categories for common expenses
  - Create custom categories with unique icons and colors
  - Category-based budget limits with notifications
- 📅 **Advanced Date Tracking**:
  - View expenses by day, week, month, or custom date range
  - Recurring expense support
  - Calendar view for expense distribution
- 🌓 **Personalized Experience**:
  - Switch between dark and light modes
  - Customizable accent colors and themes
  - Adjustable currency formats
- 📱 **Reliable Offline Support**:
  - Full functionality without internet connection using Hive local storage
  - Background sync when connection resumes
- 📊 **Comprehensive Analytics**:
  - Visual spending breakdown through intuitive charts and graphs
  - Spending trends over time
  - Category comparison analytics
- 💾 **Secure Data Management**:
  - All data stored locally on device with encryption
  - Optional biometric authentication
  - Export/import data in various formats (CSV, PDF)
- 🔔 **Smart Notifications**:
  - Budget alerts when approaching limits
  - Reminder for pending expense logging
  - Monthly spending reports

## Technology Stack

- **Framework**: Flutter
- **State Management**: Provider
- **Local Storage**: Hive
- **Charts**: fl_chart
- **UI Components**: Material Design

## Screenshots

![Daily Expense View](assets/images/image.png)
_Daily expense tracking screen showing spending summary and transaction list in dark mode_

## Installation

1. **Clone the repository**

   ```
   git clone https://github.com/mulualeme/expense-tracker-app.git
   ```

2. **Navigate to project directory**

   ```
   cd expense-tracker-app
   ```

3. **Install dependencies**

   ```
   flutter pub get
   ```

4. **Run the app**
   ```
   flutter run
   ```

## Usage Guide

### Adding an Expense

1. Tap the '+' button on the home screen
2. Enter the amount
3. Select or create a category
4. Add date, notes, or receipt image if desired
5. Save the expense

### Viewing Analytics

1. Navigate to the Analytics tab
2. Select your preferred time period
3. Explore different chart types for insights

### Managing Categories

1. Go to Settings > Categories
2. Add, edit or delete categories
3. Customize with colors and icons

## Roadmap

- [ ] Cloud synchronization
- [ ] Multiple account/wallet support
- [ ] Budget planning tools
- [ ] Receipt scanning with OCR
- [ ] Currency conversion for travel expenses
- [ ] Web application version

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
