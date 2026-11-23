# Kalbar Kite Admin Worker

Cloudflare Worker serving the Kalbar Kite admin dashboard and its protected API backed by Firebase Authentication and Firestore.

## Admin capabilities

- Admin sign-in and role verification.
- Overview counts and monthly content summaries.
- Manage members, posts, stories, blood posts, information posts, events, history posts, pantun, and dictionary entries.
- Manage public app settings.
- Create admin accounts and send password-reset emails.
- Import legacy content and inspect admin audit records.

## Configuration

Configure the Worker environment variables and bindings already used by the admin API:

- `FIREBASE_PROJECT_ID`
- `FIREBASE_WEB_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_SERVICE_ACCOUNT` (Firestore datastore access for the protected admin API)
- `KALBAR_OWNER_UID` (optional owner-specific admin controls)

## Notification system reset

Legacy notification delivery has been removed from this Worker and from the Firebase Functions source. The admin notification page and notification collection API are intentionally not exposed by this Worker while the replacement is being designed in the app.

Existing Firestore notification documents and device-token records are not deleted by this source cleanup.
