# 🚨 CRITICAL: Fix for White Screen / Crash

The app was crashing on startup because of a **Database Conflict** (Hive Type ID Collision).
Both `AvatarHive` and `ChatHive` were trying to use **ID 2**.

## ✅ What I Fixed
I have changed `ChatHive` to use **ID 3** (Unique).

## ⚠️ YOU MUST DO THIS NOW
Because the database structure changed, the old data on your device is invalid and will crash the app.

1. **STOP** the app completely.
2. **UNINSTALL** the app from your device/emulator. (Long press icon -> App Info -> Uninstall)
3. **RUN** the app again: `flutter run`

**If you do not uninstall, the white screen will persist!**

---

### Technical Details
- Modified `lib/hive/chat_hive_model.dart` to use `@HiveType(typeId: 3)`
- Manually patched `lib/hive/chat_hive_model.g.dart` to use `typeId = 3`
