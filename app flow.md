# Project Overview

This is a multi-tenant e-commerce Flutter app. One codebase, one app on the
Google Play Store, but it serves multiple shops. Each shop has its own
branding (colors, logo, name) stored in the database.

The app supports two entry methods: Deep Links and QR Codes. Both methods
resolve to the same internal flow — a URL that carries a shop ID.

---

# How a User Enters a Specific Shop

## Method 1: Deep Link

The shop owner shares a URL with their customers (via WhatsApp, Instagram bio,
printed flyer, etc.):

  https://yourapp.com/shop/{shopId}

When a customer taps this URL on Android:
- If the app is NOT installed → Android opens the Play Store listing for this app.
- If the app IS installed → Android opens the app directly and passes the URL
  to it via the App Links / Intent system.

The app reads the shopId from the URL path and loads that shop's data.

## Method 2: QR Code

The shop owner has a printed QR code (on the counter, bags, flyers, etc.).
The QR code encodes the exact same URL:

  https://yourapp.com/shop/{shopId}

When a customer scans this QR with their camera:
- Android recognizes the URL and triggers the same App Links flow as above.
- The rest of the flow is identical to Method 1.

There is no separate QR handling in the app. QR is just a physical delivery
mechanism for the same deep link URL.

---

# App Flow After Receiving a Shop URL

1. App launches (cold start from link) or receives the link while already running.

2. AppLinks package intercepts the incoming URI.

3. App extracts shopId from the URI:
   uri = "https://yourapp.com/shop/abc-123"
   shopId = "abc-123"

4. App calls ShopRepository.getShopById(shopId) which fetches from Supabase:
   - shop name
   - primary color (hex string)
   - secondary color (hex string)  
   - logo URL (Supabase Storage)
   - is_active (bool) — false if subscription expired

5. If is_active is false → show "Shop unavailable" screen. Do not proceed.

6. ShopConfig model is created from the fetched data.

7. ShopThemeCubit receives the ShopConfig and emits a new ThemeData:
   - AppBar color = primaryColor
   - Button color = primaryColor
   - ColorScheme = built from primaryColor via ColorScheme.fromSeed()

8. MaterialApp rebuilds with the new ThemeData.

9. ShopCubit stores the current ShopConfig in state.

10. App navigates to ShopHomeScreen which displays:
    - Shop logo (CachedNetworkImage from logoUrl)
    - Shop name
    - Product listings filtered by shopId

The customer sees only this shop's products and branding.
They have no indication that other shops exist in the same app.

---

# What Happens if the App Opens Without a Link

If the user opens the app directly (from home screen icon, not from a link):
- Show a ShopListScreen with all active shops.
- User picks a shop manually.
- Flow continues from step 4 above.

This is a fallback. The primary intended entry is always via link or QR.

---

# Data Isolation

Every database query is scoped to the current shopId.
Products, orders, and categories are always filtered by shopId.
A customer browsing Shop A can never see Shop B's products.

Row Level Security (RLS) in Supabase enforces this at the database level.

---

# Merchant Side (Separate App)

There is a separate Flutter app for shop owners (admin app).
Shop owners log in, manage their products, and view incoming orders.
Orders are pushed to the merchant app via Firebase Cloud Messaging (FCM).
Each shop subscribes to its own FCM topic: orders_shop_{shopId}

This document covers the customer app only.

---

# Tech Stack (Customer App)

- Flutter + Dart
- Clean Architecture (data / domain / presentation layers)
- BLoC / Cubit for state management
- Supabase for database, auth, and file storage
- Firebase FCM for push notifications
- app_links package for Deep Link / App Links handling
- cached_network_image for logo loading
- RLS in Supabase for data isolation per shop

---

# Android Setup Required for Deep Links

The app must declare an intent filter in AndroidManifest.xml for
android:autoVerify="true" on the yourapp.com domain.

A Digital Asset Links file must be hosted at:
  https://yourapp.com/.well-known/assetlinks.json

This file maps the domain to the app's package name and signing certificate.
Without this, Android will not automatically open links in the app — it will
ask the user to choose a browser instead.

---

# Summary of Entry Points

  QR scan  ──┐
             ├──► yourapp.com/shop/{shopId} ──► app opens ──► load shop ──► show shop UI
  Link tap ──┘
  
  Direct open (no link) ──► show shop list ──► user picks shop ──► same flow
