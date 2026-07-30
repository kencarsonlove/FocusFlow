# FocusFlow Firebase Setup

FocusFlow uses Firebase for:

- Email/password account creation.
- A 6-digit login verification code every time someone logs in.
- Cloud Firestore user data storage.

## Firebase Console

1. Open your Firebase project.
2. Go to Authentication > Sign-in method.
3. Enable Email/Password.
4. Go to Firestore Database and create a database.
5. Install Firebase Extensions > Trigger Email.
6. Configure Trigger Email to watch this collection:

```txt
mail
```

7. Make sure your app config files are in the project:
   - iOS: `ios/Runner/GoogleService-Info.plist`
   - Android: `android/app/google-services.json`

## Firestore Data

The app saves each user profile here:

```txt
users/{firebaseAuthUid}
```

The app asks Firebase to send verification code emails by creating docs here:

```txt
mail/{autoId}
```

## Firestore Rules

Use rules like this so users can read/write their own app data and create login email requests only after their password is correct:

```txt
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /mail/{mailId} {
      allow create: if request.auth != null;
      allow read, update, delete: if false;
    }
  }
}
```

## Flutter Run

Run normally:

```sh
flutter run
```
