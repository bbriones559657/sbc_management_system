# Login background images

The login screen uses these three processed café photos as a softly blended
background:

- `login_exterior.webp` — exterior view
- `login_storefront.webp` — signed storefront view
- `login_interior.webp` — café interior

The three source photos are retained alongside these optimized WebP copies.
The display versions are scaled with Lanczos and lightly sharpened. Update the
asset entries in `pubspec.yaml` and paths in `lib/screens/auth/login_screen.dart`
when changing filenames.
