# 🚀 TestFlight & App Store Deployment Guide

This guide explains how to automatically build, sign, and upload **MZ VC Phonebook** to **Apple TestFlight** and the **App Store** using **GitHub Actions**—entirely in the cloud, without needing a Mac.

---

## 📋 Prerequisites

1. An **Apple Developer Account** ([developer.apple.com](https://developer.apple.com))
2. App created in **App Store Connect** ([appstoreconnect.apple.com](https://appstoreconnect.apple.com)) with:
   - **Bundle ID**: `in.gov.mizoram.vcphonebook`
   - **App Name**: `MZ VC Phonebook`

---

## 🔑 Step 1: Generate App Store Connect API Key

Apple provides dedicated API keys for automated CI/CD deployments:

1. Log into [App Store Connect](https://appstoreconnect.apple.com).
2. Go to **Users and Access** → **Integrations** (or **Keys**) tab.
3. Under **App Store Connect API**, click the **`+`** (Add) button.
4. Fill in:
   - **Name**: `GitHub Actions CI`
   - **Access**: `App Manager` or `Admin`
5. Click **Generate**.
6. Note the following three values:
   - **Issuer ID**: Displayed at the top of the Keys page (UUID format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`).
   - **Key ID**: Listed in the row for your newly created key (e.g., `2X9R4HX40X`).
   - **Download API Key**: Click **Download API Key** to get the `AuthKey_<KEY_ID>.p8` private key file. *(Save this carefully, Apple only lets you download it once)*.

---

## 🔐 Step 2: Add Secrets to GitHub

In your GitHub repository:

1. Open **[GitHub Repository Settings](https://github.com/xspace60-art/MZVCPhonebook-iOS/settings/secrets/actions)**.
2. In the left sidebar, click **Secrets and variables** → **Actions**.
3. Under **Repository secrets**, click **New repository secret** and add the following:

| Secret Name | Value |
| :--- | :--- |
| `APP_STORE_CONNECT_KEY_ID` | Your Key ID (e.g. `2X9R4HX40X`) |
| `APP_STORE_CONNECT_ISSUER_ID` | Your Issuer ID (e.g. `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`) |
| `APP_STORE_CONNECT_API_KEY_P8` | The entire content of your downloaded `.p8` file (including `-----BEGIN PRIVATE KEY-----` and `-----END PRIVATE KEY-----`) |

---

## 📲 Step 3: Automatic TestFlight Delivery

Once these three secrets are added to your repository:

1. Every `git push` to `main` triggers `.github/workflows/build-ios.yml`.
2. The cloud runner on macOS compiles the app, signs it with your official Apple Developer account, and uploads it to **App Store Connect / TestFlight**.
3. Within minutes, your testers can open the **TestFlight** app on their iPhone and immediately test the newest version!

---

## 🛠️ Testing Without an Apple Developer Account (Ad-Hoc)

If you don't yet have an active Apple Developer Program membership:
- GitHub Actions automatically compiles and packages an ad-hoc `.ipa` artifact: **`MZVCPhonebook-iOS-IPA`**.
- You can download this `.ipa` from the Actions summary page and install it using:
  - **AltStore / Sideloadly** (Free on Windows PC)
  - **TrollStore** (on compatible iOS versions)
  - Or simply test instantly via the web PWA version by tapping **Share > Add to Home Screen** in Safari on iPhone.
