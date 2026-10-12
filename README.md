# Chatter

تطبيق دردشة مبني باستخدام Flutter يربط المستخدمين بالأدمن في محادثات مباشرة. يوفّر تسجيل حسابات، قائمة محادثات للإدارة، وإرسال واستقبال الرسائل مع تحديثات فورية عبر Firebase.

## المزايا

- إنشاء حساب وتسجيل الدخول عبر Firebase Authentication باستخدام البريد الإلكتروني وكلمة المرور.
- حفظ اسم المستخدم والبريد الإلكتروني ودوره في Cloud Firestore.
- محادثة خاصة بين كل مستخدم والأدمن.
- لوحة تحكم للأدمن تعرض المحادثات وتتيح فتحها والرد على المستخدمين.
- تحديث الرسائل وقائمة المحادثات فورياً باستخدام Firestore streams.
- عرض آخر رسالة ووقت الرسالة واسم المستخدم.
- واجهة عربية مع خط Poppins وتصميم متوافق مع Flutter Material.

## التقنيات

- **Flutter وDart** لبناء التطبيق.
- **Firebase Authentication** لإدارة تسجيل الحسابات والدخول.
- **Cloud Firestore** لتخزين المستخدمين والمحادثات والرسائل.
- **StreamBuilder وFirestore snapshots** لتحديث الواجهات لحظياً.
- **Material Design** و**Poppins** لعناصر وتصميم الواجهة.

## بنية البيانات

```text
users/{uid}
  uid, email, name, isAdmin

chats/{userUid_adminUid}
  userUid, adminUid, lastMessage, lastTimestamp
  messages/{messageId}
    text, senderUid, senderName, timestamp
```

تُخزن الرسائل كمجموعة فرعية داخل مستند المحادثة، ويُخزن `timestamp` كعدد milliseconds منذ Unix epoch. كما يحتفظ مستند المحادثة بآخر رسالة ووقتها لتسهيل عرض قائمة المحادثات.

## بنية المشروع

```text
lib/
  main.dart
  pages/
    login.dart
    signup.dart
    splash.dart
    chatterScreen.dart
    admin_dashboard.dart
    user_chat_screen.dart
  widgets/
assets/
  fonts/
  images/
```

## التشغيل

المتطلبات: Flutter SDK، وبيئة تشغيل مثل Android Studio أو جهاز Android، ومشروع Firebase مُعدّ للتطبيق.

```powershell
flutter pub get
flutter run
```

## إعداد Firebase

1. أنشئ مشروعاً في Firebase وفعّل **Authentication > Email/Password** و**Cloud Firestore**.
2. أضف إعداد Firebase لكل منصة باستخدام FlutterFire CLI أو دليل إعداد Firebase الرسمي.
3. لأندرويد، استخدم ملف `google-services.json` الخاص بمشروعك في `android/app/`.
4. للويب، حدّث خيارات Firebase في `lib/main.dart` لتطابق مشروعك. أكمل إعدادات المنصات الأخرى حسب دليل Firebase.
5. استبدل قيمة `ADMIN_UID` التجريبية بمعرف حساب الأدمن الحقيقي في `lib/main.dart` و`lib/pages/chatterScreen.dart`.
6. أنشئ قواعد Firestore تقيّد المستخدم بمحادثته وتسمح للأدمن بالوصول وفق دوره. لا تستخدم قواعد الاختبار المفتوحة في الإنتاج.

> إعدادات Firebase الموجودة في التطبيق خاصة ببيئة التطوير. إعدادات العميل ليست بديلاً عن قواعد Firestore؛ راجع صلاحيات قاعدة البيانات وقيود مفاتيح API قبل نشر التطبيق للعامة.

## ملاحظات قبل النشر

- حساب الأدمن يحتاج إلى `isAdmin: true` في مستند `users/{uid}`؛ الحسابات المنشأة من التطبيق تُسجّل كمستخدم عادي.
- لا ترفع مفاتيح توقيع Android أو ملفات حساب خدمة Firebase أو كلمات المرور وملفات البيئة.
- أضف لقطات شاشة حقيقية للتطبيق إلى المستودع عند إعداد نسخة العرض للأعمال.

## المطور

**Omar Almahjari**
