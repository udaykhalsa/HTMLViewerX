# HTML Studio & Telegram Exporter

HTML Studio is a full-stack project consisting of a **Flutter Web** frontend and a **Django REST** backend. It provides a live HTML/CSS editing environment where users can write code, see a real-time rendered preview, export their creations as HTML, PNG, or PDF, and seamlessly forward those exports directly to a designated Telegram group via the backend API.

## 🚀 Key Features

### Frontend (HTML Studio)
* **Live Editor & Preview:** Dual-pane interface with a code editor on the left and a live, zoomable HTML iframe preview on the right.
* **Local Exports:** Download your rendered HTML components locally as `.html`, `.png`, or `.pdf` files.
* **Cloud Actions:** One-click functionality to send the generated PNG or PDF directly to Telegram.
* **Custom JS Injection:** Utilizes `html2canvas` via Dart-JS interop to accurately capture the DOM and render it to a high-quality image.

### Backend (Telegram Updates API)
* **REST API:** Built with Django REST Framework to accept `multipart/form-data` file uploads.
* **Async Telegram Integration:** Uses `python-telegram-bot` to asynchronously forward uploaded PNGs and PDFs to a configured Telegram Chat ID.
* **Error Handling:** Robust error catching for Telegram API limits, invalid tokens, and network failures.

---

## 🛠️ Tech Stack

**Frontend:**
* Flutter (Web)
* Dart
* Packages: `dio`, `pdf`, `file_saver`, `web`

**Backend:**
* Python 3.x
* Django & Django REST Framework
* `python-telegram-bot`
* `django-cors-headers`

---

## 📂 Project Structure

```text
├── html_viewer/                 # Flutter Web Frontend
│   ├── lib/
│   │   └── main.dart            # Main application logic, UI, and API calls
│   ├── pubspec.yaml             # Flutter dependencies
│   └── web/                     # Web-specific assets
│
└── telegram_updates/            # Django Backend
    ├── manage.py                # Django entry point
    ├── telegram_updates/        # Django project settings & routing
    │   ├── settings.py          # App config, CORS, and Telegram tokens
    │   └── urls.py              # Main URL routing
    └── updates/                 # API Application
        ├── views.py             # Logic for handling uploads & Telegram bot
        └── urls.py              # API endpoint routing