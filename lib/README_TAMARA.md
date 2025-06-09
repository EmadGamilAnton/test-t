# نظام دفع تمارا - Tamara Payment Integration

## نظرة عامة
هذا المشروع يحتوي على تطبيق Flutter مع تكامل نظام دفع تمارا باستخدام WebView.

## الميزات
- إرسال طلب دفع إلى API تمارا
- عرض صفحة الدفع في WebView
- معالجة نتائج الدفع (نجاح/فشل/إلغاء)
- واجهة مستخدم باللغة العربية

## كيفية الاستخدام

### 1. إدخال البيانات
- رقم الحجز (Reservation GUID)
- رمز الجهاز (Device Token)

### 2. بدء عملية الدفع
- اضغط على زر "ادفع بتمارا"
- سيتم إرسال طلب إلى API تمارا
- إذا نجح الطلب، ستفتح صفحة الدفع في WebView

### 3. إكمال الدفع
- أكمل عملية الدفع في صفحة تمارا
- سيتم إرجاعك تلقائياً للتطبيق مع النتيجة

## تفاصيل تقنية

### API Endpoint
```
POST https://takeed.runasp.net/api/v1/tamara/create-session
```

### Request Body
```json
{
  "paymentMethod": "tamara",
  "reservationGuid": "bf44a8641bf8400ea7683a411a995c13",
  "deviceToken": "string"
}
```

### Response Format
```json
{
  "statusCode": 200,
  "success": true,
  "message": "Completed successfully",
  "data": "https://checkout-sandbox.tamara.co/checkout/..."
}
```

### الملفات المهمة
- `lib/services/tamara_service.dart` - خدمة API
- `lib/screens/payment_screen.dart` - صفحة الدفع
- `lib/models/` - نماذج البيانات

### Callback URL Pattern
```
https://takeed.sa/tamara/?paymentStatus=approved&orderId=bc0eab28-b964-4df6-8ed5-15f766dbbf13
```

#### Payment Status Values:
- `approved` → تم الدفع بنجاح
- `declined` → فشل الدفع
- `cancelled` → تم إلغاء الدفع

### Dependencies المستخدمة
- `webview_flutter` - للتعامل مع WebView
- `http` - لاستدعاء API
- `url_launcher` - للتعامل مع الروابط

## ملاحظات
- تأكد من أن لديك اتصال بالإنترنت
- التطبيق يتعرف تلقائياً على callback URLs من تمارا
- يمكن تخصيص واجهة المستخدم حسب الحاجة
