
<!-- Logo -->
<p align="center">
  <img src="Users_app/asset/images/bahj.png" alt="Bahja Platform Logo" width="180"/>
</p>

<h1 align="center">Bahja Platform</h1>

<p align="center">
  <em>Empowering Digital Events with Smart Automation</em>  
</p>

<p align="center">
  <strong>Lead Engineer:</strong> Jamal Al-Awady  
</p>

---

## 🚀 Overview

**Bahja Platform** is a comprehensive multi-application ecosystem built to revolutionize event and wedding management.  
It provides an intelligent, fully integrated solution that connects **clients**, **service providers**, and **administrators** in a unified digital environment.  

Built entirely with **Flutter** and powered by **Firebase**, Bahja delivers a seamless real-time experience, from booking and payments to chat, notifications, and AI-powered digital invitations.

---

## 🧭 System Architecture

The Bahja ecosystem is composed of **three Flutter applications**, each with a defined purpose and communication flow through Firebase services:

```
[ Users App ]  →  Firebase Auth / Firestore / FCM / Storage  ←  [ Providers App ]
                          ↑
                          ↓
                     [ Admin App ]
```

### 🔹 Apps Breakdown

| Application | Description | Platform |
|--------------|-------------|-----------|
| **Users App** | For clients to explore services, make bookings, manage invitations, and communicate with providers. | Android |
| **Services Providers App** | For vendors to list their services, manage bookings, and handle transactions. | Android |
| **Admin App** | Management and moderation panel to control users, providers, and monitor analytics. | Android |

---

## 🧩 Tech Stack

| Layer | Technology |
|-------|-------------|
| **Frontend** | Flutter (Dart) |
| **Backend / Cloud** | Firebase Firestore, Firebase Auth, Firebase Storage, Cloud Functions, Cloud Messaging |
| **AI / NLP** | Dialogflow (Google) for intelligent assistant features |
| **Payments** | Integrated Wallet & API-ready design for Kremi Wallet or local bank gateways |
| **Maps & Geo** | Google Maps SDK |
| **State Management** | Provider / Riverpod pattern |
| **Version Control** | Git & GitHub |

---

## 🗂️ Project Structure (Extracted from Actual Code)

```
Bahja Platform/
├── Admin_app/
│   ├── assets/
│   └── lib/
│       ├── components/
│       ├── models/
│       ├── providers/
│       ├── screens/
│       └── widgets/
│
├── services_providers/
│   ├── android/
│   ├── ios/
│   ├── lib/
│   │   ├── chat/
│   │   │   ├── models/
│   │   │   ├── screens/
│   │   │   ├── services/
│   │   │   └── widgets/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── widgets/
│   └── asset/
│       ├── config/service_account/
│       ├── fonts/
│       └── images/
│
└── Users_app/
    ├── android/
    ├── ios/
    ├── lib/
    │   ├── models/
    │   ├── screens/
    │   ├── services/
    │   ├── utils/
    │   └── widgets/
    └── asset/
        ├── config/service_account/
        ├── dialogflow/
        ├── fonts/
        └── images/
```

---

## ⚙️ Core Features

### 🎯 Client App
- Discover and filter event services by category, location, and price.
- Manage bookings and payments with a built-in wallet.
- Smart invitation generator with QR codes.
- Chat directly with service providers.
- Personalized recommendations using AI (Dialogflow).

### 🏢 Provider App
- Create, edit, and manage offered services.
- Accept, decline, or reschedule bookings.
- Manage wallet transactions and offers.
- Real-time chat and notification system.
- Dashboard with daily analytics and reviews.

### 🛠️ Admin App
- Comprehensive control over users and providers.
- Approve new vendors and moderate content.
- Monitor transactions and complaints.
- Visual dashboards for analytics and KPIs.

---

## 🧱 Database Schema (Firestore Overview)

| Collection | Key Fields | Description |
|-------------|-------------|--------------|
| **users** | uid, username, email, typeUser, wallet, fcmToken | All user roles |
| **providers** | companyName, serviceType, offers, priceRange, bookedDays | Registered vendors |
| **services** | serviceId, name, images, description | Offered event services |
| **bookings** | bookingId, userId, providerId, status, finalPrice, eventDate | Client-Provider transactions |
| **invitations** | inviteId, eventType, eventDate, invitees, qrCode | Digital invitations |
| **chats** | chatId, participants[], lastMessage, messages[] | Realtime conversations |
| **notifications** | userId, title, body, timestamp | Push notifications |

---

## 🔧 Installation & Setup

> Requires Flutter (>=3.10), Firebase CLI, and Android Studio / VS Code.

```bash
# Clone the project
git clone https://github.com/jamaljmeel/Bahja-Platform.git
cd Bahja-Platform

# Install dependencies
flutter pub get
```

### 🧩 Firebase Setup
1. Create a new Firebase project.  
2. Enable **Authentication**, **Firestore**, **Storage**, **Cloud Messaging**, and **Functions**.  
3. Add Android/iOS apps → Download `google-services.json` and `GoogleService-Info.plist`.  
4. Place them inside respective `/android/app`  directories.  
5. Run the project:
```bash
flutter run
```

---

## 🔐 Firebase Security Rules (Sample)

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    match /providers/{providerId} {
      allow read: if true;
      allow write: if request.auth.token.role == "provider";
    }
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🧠 System Architecture Diagram

```
+--------------------------------------------------------+
|                        Bahja Platform                  |
|--------------------------------------------------------|
|   Flutter Frontend Layer                               |
|   ├── Users App (Client)                               |
|   ├── Providers App (Vendors)                          |
|   └── Admin App (Control Panel)                        |
|                                                        |
|   ↕ Communicates via                                   |
|   Firebase Services: Auth | Firestore | Storage | FCM   |
|                                                        |
|   Cloud Functions handle:                              |
|   - Booking Notifications                              |
|   - QR Code Generation                                 |
|   - Automated Reports                                  |
+--------------------------------------------------------+
```

---

## 🖼️ Screenshots

> Below are categorized screenshots for each application in the **Bahja Platform** ecosystem.  
> Each group of screenshots shows a different system module.

---

### 📱 Users App

#### 🔐 login & Welcome
<p align="center">
  <img src="screenshots/users/snap.png" width="220"/>
  <img src="screenshots/users/login.png" width="220"/>
</p>

---

#### 🏠 Home & More
<p align="center">
  <img src="screenshots/users/home.png" width="220"/>
  <img src="screenshots/users/dark.png" width="220"/>
  <img src="screenshots/users/more.png" width="220"/>
</p>

---
#### 🏠 Services & Details
<p align="center">
  <img src="screenshots/users/serv.png" width="220"/>
  <img src="screenshots/users/prov_services.png" width="220"/>
  <img src="screenshots/users/prov_ser.png" width="220"/>
  <img src="screenshots/users/prov_ser2.png" width="220"/>
  <img src="screenshots/users/map.png" width="220"/>
</p>

---

#### 💬 Wallet 
<p align="center">
  <img src="screenshots/users/Wallet.png" width="220"/>
</p>

---
#### 💬 Chat System
<p align="center">
  <img src="screenshots/users/chat.png" width="220"/>
</p>

---

#### 📅 Booking System
<p align="center">
  <img src="screenshots/users/bok.png" width="220"/>
  <img src="screenshots/users/book.png" width="220"/>
</p>

---

#### 💌 Digital Invitations
<p align="center">
  <img src="screenshots/users/Invitations.png" width="220"/>
  <img src="screenshots/users/create.png" width="220"/>
  <img src="screenshots/users/add.png" width="220"/>
  <img src="screenshots/users/qr.png" width="220"/>
</p>

---

#### 🤖 Smart Assistant
<p align="center">
  <img src="screenshots/users/chatbot.png" width="220"/>
</p>

---

#### 📞 Contact & Edit profile
<p align="center">
  <img src="screenshots/users/contact.png" width="220"/>
  <img src="screenshots/users/acc.png" width="220"/>
</p>

---

### 🏢 Providers App

#### 🔐 Home & Drawer
<p align="center">
  <img src="screenshots/providers/servi.png" width="220"/>
  <img src="screenshots/providers/drawer.png" width="220"/>
</p>

---

#### 🛎️ Services Management
<p align="center">
  <img src="screenshots/providers/add.png" width="220"/>
  <img src="screenshots/providers/add2.png" width="220"/>
  <img src="screenshots/providers/add3.png" width="220"/>
  <img src="screenshots/providers/edit.png" width="220"/>
</p>

---

#### 📅 Booking Management
<p align="center">
  <img src="screenshots/providers/book.png" width="220"/>
</p>

---

#### 💬 Chat
<p align="center">
  <img src="screenshots/providers/chat.png" width="220"/>
</p>


---

### 🛠️ Admin App

#### 🔐  Dashboard
<p align="center">
  <img src="screenshots/admin/drawer.png" width="260"/>
  <img src="screenshots/admin/dash.png" width="260"/>
</p>

---

#### 👥 Users & Providers Management
<p align="center">
  <img src="screenshots/admin/acc.png" width="260"/>
  <img src="screenshots/admin/services.png" width="260"/>
  <img src="screenshots/admin/prive.png" width="260"/>
  <img src="screenshots/admin/prov_serv.png" width="260"/>
</p>

---

#### 💼 Bookings 
<p align="center">
  <img src="screenshots/admin/book.png" width="260"/>
</p>

---

#### 🚨 Supper & Notifications
<p align="center">
  <img src="screenshots/admin/supp.png" width="260"/>
  <img src="screenshots/admin/not.png" width="260"/>
</p>

---

<p align="center">
  ✨ Each section showcases the main modules and workflows of the Bahja Platform applications ✨
</p>


---

## 🌟 Highlights

- **3 Fully Integrated Flutter Apps**  
- **Realtime Firebase Cloud Backend**  
- **AI-powered Invitations & Assistant**  
- **Clean Modular Architecture**   
- **Scalable Database Design**  
- **Role-based Authentication & Access Control**

---

## 🧭 Future Roadmap

- Integrate advanced payment gateways.  
- Deploy Admin panel to Firebase Hosting.  
- Implement analytics visualization using Recharts.  
- Expand AI assistant for smart event planning.  

---

## 👨‍💻 Lead Engineer

**Jamal Al-Awady**  
Software Engineer & System Architect  
> Building intelligent digital ecosystems with Flutter & Firebase.



