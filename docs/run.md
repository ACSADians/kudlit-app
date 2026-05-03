Fix 1 — add --no-dds flag (quickest fix):
  flutter run -d emulator-5554 --no-dds

  Fix 2 — if that still fails, also disable auth
  codes:
  flutter run -d emulator-5554 --no-dds
  --disable-service-auth-codes