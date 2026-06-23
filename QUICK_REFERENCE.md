# ឯកសារយោង / Quick Reference Guide
# KneaYerng Service Center - Issues & Solutions Quick Guide

---

## 🔴 Critical Issues (Fix First)

### 1️⃣ Git Line Ending Config
```bash
cd app_ky_service_center
cat > .gitattributes << 'EOF'
* text=auto eol=lf
*.dart diff=dart
*.yaml diff=yaml
EOF
git add .gitattributes && git commit -m "fix: line endings"
```

### 2️⃣ Firebase Credentials
- Add `GoogleService-Info.plist` to `ios/Runner/`
- Add `google-services.json` to `android/app/`
- Rebuild: `flutter clean && flutter pub get`

### 3️⃣ OTP Service Testing
```bash
# Test endpoints in Postman/Insomnia
POST /api/auth/send-otp
{"phone": "85512345678"}

POST /api/auth/verify-otp
{"phone": "85512345678", "code": "123456"}
```

---

## 🟡 High Priority Issues

### Cart Screen Refactoring
**Files to create:**
- `widgets/cart_items_list.dart`
- `widgets/cart_summary.dart`
- `widgets/checkout_button.dart`

**Update:** `screens/cart/cart_screen.dart` to use components

### Search Results Refactoring
**Split into:**
- `widgets/search_filters.dart`
- `widgets/search_results_list.dart`
- `widgets/product_grid.dart`

### Add Unit Tests
```bash
flutter test --coverage
# Target: 80% coverage
```

---

## 📋 Testing Commands

```bash
# Unit tests
flutter test

# Specific test file
flutter test test/services/api_service_test.dart

# With coverage
flutter test --coverage

# Backend tests
php artisan test
```

---

## 🚀 Deployment Steps

```bash
# 1. Code quality check
flutter analyze

# 2. Run tests
flutter test

# 3. Build
flutter build apk --release
flutter build ios --release

# 4. Backend
php artisan migrate --force
php artisan cache:clear

# 5. Verify
# - Test on real devices
# - Check Firebase events
# - Monitor logs
```

---

## 📊 Current State Summary

| Category | Status | Action |
|----------|--------|--------|
| Git Config | ⚠️ Broken | Fix line endings |
| Firebase | ❌ Missing | Add credentials |
| OTP | ⚠️ Untested | Run tests |
| API | ⚠️ Partial | Add error handling |
| Cart | 🟡 Large | Refactor components |
| Search | 🟡 Large | Refactor components |
| Tests | ❌ Missing | Add unit tests |
| Performance | ⚠️ Unknown | Profile & optimize |

---

## 🔗 File References

### Key Files Changed
- `app_ky_service_center/lib/main.dart` - Firebase init
- `app_ky_service_center/lib/services/api_service.dart` - API handling
- `app_ky_service_center/lib/screens/cart/cart_screen.dart` - 1441 lines
- `app_ky_service_center/lib/screens/search/search_results_screen.dart` - 1880 lines

### Created Documents
- `SYSTEM_ANALYSIS_AND_SOLUTIONS.md` - Full analysis
- `IMPLEMENTATION_GUIDE.md` - Step-by-step guide
- `QUICK_REFERENCE.md` - This file

---

## ✅ Verification Checklist

### Before Committing
- [ ] `flutter analyze` passes
- [ ] Code is formatted
- [ ] Tests pass
- [ ] No console warnings

### Before Deploying
- [ ] All critical issues fixed
- [ ] Firebase configured
- [ ] OTP tested
- [ ] Performance verified
- [ ] Security audit done

---

## 🆘 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| LF/CRLF warnings | Add `.gitattributes` |
| Firebase errors | Add config files |
| OTP not working | Verify Infobip settings |
| Slow screens | Use `ListView.builder`, optimize images |
| Large diffs | Break into smaller components |

---

## 📞 Contact & Support

- **Issues Documentation:** `SYSTEM_ANALYSIS_AND_SOLUTIONS.md`
- **Implementation Steps:** `IMPLEMENTATION_GUIDE.md`
- **Quick Answers:** This file

---

**Generated:** June 19, 2026  
**Version:** 1.0  
**Status:** Ready for Implementation
