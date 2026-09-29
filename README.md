# HYperRegedit / OGIOS

هذا هو المشروع الكامل المرسل في أرشيف MediaFire، وليس نموذجًا جديدًا. يحتوي على مشروع Xcode الأصلي، الشاشات، الخدمات، الأصول، ملفات الـpatch، ووحدات العمل الداخلية.

## البنية

- `ThreeOneOSFive/views`: واجهات التطبيق ونظام التصميم.
- `ThreeOneOSFive/helpers`: الخدمات الداخلية مثل إدارة الملفات، المشاريع، التنظيف، التخزين، الأرشفة، وإدارة التفعيل.
- `ThreeOneOSFive/Assets.xcassets`: الأيقونات والصور والخلفيات.
- `ThreeOneOSFive/Patches`: حزم patch المضمنة في التطبيق.
- `ThreeOneOSFive/exploit` و`ThreeOneOSFive/kexploit`: ملفات الدعم الأصلية للمشروع كما وردت في المصدر.
- `ThreeOneOSFive.xcodeproj`: مشروع Xcode الكامل.
- `build_unsigned.sh`: بناء IPA غير موقّع على macOS.

## التفعيل

تم استبدال التحقق الشبكي بمدير تفعيل محلي داخل `helpers/LicenseManager.swift`. لا يحتاج التطبيق إلى API server لتفعيل الترخيص، والمفتاح المقبول هو:

```text
KSENSI-11
```

يحفظ التفعيل في Keychain على الجهاز، ويمكن إزالة التفعيل من داخل التطبيق عبر `deactivate()`.

## توافق iOS

الحد الأدنى لإصدار iOS في مشروع Xcode هو 16.0. واجهة التطبيق تستهدف iOS 16 فما بعد، لكن توافق الـkernel exploit منفصل ويظل محصورًا بالإصدارات والبِنى المتحقق منها في `ThreeOneOSFive/helpers/SupportPolicy.swift`. iOS 16 ليس ضمن نطاق الـexploit المتحقق منه، لذلك لن يحاول التطبيق تشغيله هناك.

## البناء

يتطلب البناء جهاز macOS مع Xcode. يمكن تشغيل:

```bash
./build_unsigned.sh
```

ثم استخدام GitHub Actions من خلال Workflow البناء الموجود في `.github/workflows/objective-c-xcode.yml`.
