# Firebase Storage Rules

This document outlines the security rules for Firebase Storage in the Eventati Book application.

## Important Note on Vendor Implementation

- Vendors will have their own separate admin projects/applications where they can upload their details and images
- The Eventati Book app will only display vendor information, handle bookings, and process payments
- The app will not include functionality for vendors to upload images directly
- The Firebase Storage structure for services will be used to store images that are uploaded through the vendor admin projects
- The Eventati Book app will only read from these storage locations, not write to them
- Security rules reflect this: users can read service images but only admin accounts can write to them

## Overview

Firebase Storage security rules control access to files stored in Firebase Storage. These rules are defined in a rules file and are applied to all files in the storage bucket.

## Rule Structure

The rules are structured as follows:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Rules go here
  }
}
```

## Helper Functions

The following helper functions are used in the rules:

```
// Check if the user is signed in
function isSignedIn() {
  return request.auth != null;
}

// Check if the user is the owner of the resource
function isOwner(userId) {
  return isSignedIn() && request.auth.uid == userId;
}

// Check if the user is the owner of the event
function isEventOwner(eventId) {
  return isSignedIn() &&
    firestore.get(/databases/(default)/documents/events/$(eventId)).data.userId == request.auth.uid;
}

// Check if the user is an admin
function isAdmin() {
  return isSignedIn() &&
    firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 'admin';
}

// Check if the file is an image
function isImageFile() {
  return request.resource.contentType.matches('image/.*');
}

// Check if the image size is valid (less than 5MB)
function isValidImageSize() {
  return request.resource.size < 5 * 1024 * 1024;
}
```

## Rules for Different Resources

### User Profile Images

```
// User profile images
match /users/{userId}/profile_image {
  allow read: if isSignedIn();
  allow write: if isOwner(userId) && isImageFile() && isValidImageSize();
}
```

### Event Images

```
// Event images
match /events/{eventId}/images/{imageId} {
  allow read: if isSignedIn();
  allow write: if isEventOwner(eventId) && isImageFile() && isValidImageSize();
}

// Event thumbnails
match /events/{eventId}/thumbnails/{imageId} {
  allow read: if isSignedIn();
  allow write: if isEventOwner(eventId) && isImageFile() && isValidImageSize();
}
```

### Venue Images

```
// Venue images
match /venues/{venueId}/images/{imageId} {
  allow read: if isSignedIn();
  allow write: if isAdmin() && isImageFile() && isValidImageSize();
}

// Venue thumbnails
match /venues/{venueId}/thumbnails/{imageId} {
  allow read: if isSignedIn();
  allow write: if isAdmin() && isImageFile() && isValidImageSize();
}
```

### Event Thumbnails

```
// Event thumbnails
match /events/{eventId}/thumbnails/{imageId} {
  allow read: if isSignedIn();
  allow write: if isEventOwner(eventId) && isImageFile() && isValidImageSize();
}
```

### Service Images

```
// Service images (catering, photographer, etc.)
match /services/{serviceType}/{serviceId}/images/{imageId} {
  allow read: if isSignedIn();
  allow write: if isAdmin() && isImageFile() && isValidImageSize();
}

// Service thumbnails
match /services/{serviceType}/{serviceId}/thumbnails/{imageId} {
  allow read: if isSignedIn();
  allow write: if isAdmin() && isImageFile() && isValidImageSize();
}
```

## Deployment

To deploy these rules to Firebase Storage, use the Firebase CLI:

```bash
firebase deploy --only storage
```

## Testing

You can test these rules using the Firebase Storage Rules Simulator in the Firebase Console or using the Firebase CLI:

```bash
firebase emulators:start --only storage
```

## Best Practices

1. Always validate file types and sizes
2. Use Firestore data to validate ownership
3. Keep rules as simple as possible
4. Test rules thoroughly before deployment
5. Monitor storage usage and adjust rules as needed
