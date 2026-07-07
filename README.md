# Mobile Delivery Application

ระบบจัดการและติดตามการขนส่งพัสดุผ่านแอปพลิเคชันมือถือในรูปแบบ Real-time พัฒนาด้วย Flutter โดยแบ่งสิทธิ์การทำงานออกเป็น 2 บทบาทหลัก คือ ผู้ใช้งานทั่วไป (User) และ ผู้ส่งพัสดุ (Rider)

---

## เทคโนโลยีที่ใช้งาน (Technology Stack)

* **โมบายล์เฟรมเวิร์ก:** Flutter (ภาษา Dart)
* **การจัดการสถานะ (State Management):** Provider
* **การจัดการเส้นทาง (Routing):** GetX
* **ฐานข้อมูลแบบ Real-time:** Firebase Firestore (ใช้บันทึกข้อมูลหลัก เช่น ข้อมูลผู้ใช้ ข้อมูลไรเดอร์ และคำสั่งซื้อ)
* **ระบบจัดเก็บไฟล์ (Cloud Storage):** Supabase Storage (ใช้จัดเก็บไฟล์รูปภาพ เช่น ภาพโปรไฟล์ รูปภาพสินค้า และรูปถ่ายยืนยันตัวตนของไรเดอร์)
* **ระบบแผนที่ (Map Engine):** FlutterMap (แสดงผลแผนที่ผ่านไทล์แผนที่ของ OpenStreetMap ร่วมกับ Thunderforest)
* **การติดตามตำแหน่ง (Location Tracking):** Geolocator (สำหรับส่งพิกัด GPS แบบ Real-time จากฝั่งไรเดอร์ขึ้นเซิร์ฟเวอร์)

---

## สิทธิ์และฟังก์ชันการใช้งานของระบบ

### 1. บทบาทผู้ใช้งานทั่วไป (User)
* **การสมัครสมาชิกและเข้าสู่ระบบ:** ลงทะเบียนพร้อมอัปโหลดภาพโปรไฟล์ไปยัง Supabase และจัดเก็บประวัติข้อมูลใน Firestore
* **สมุดที่อยู่ (Address Book):** เพิ่ม แก้ไข ลบที่อยู่จัดส่งพัสดุ พร้อมเลือกปักหมุดพิกัดละติจูด/ลองจิจูดจากแผนที่จริงได้
* **การส่งพัสดุ (Create Parcel):** สร้างคำสั่งซื้อโดยระบุข้อมูลสินค้า ขนาด ภาพถ่ายพัสดุ และระบุพิกัดผู้ส่ง-ผู้รับปลายทาง
* **การติดตามสถานะการส่งพัสดุ (Order Tracking):** ตรวจสอบประวัติพัสดุที่เคยส่งและพัสดุที่กำลังจะได้รับ พร้อมทั้งดูแผนที่แสดงตำแหน่งและเส้นทางการวิ่งของไรเดอร์ที่กำลังมารับหรือมาส่งพัสดุแบบ Real-time

### 2. บทบาทไรเดอร์ (Rider)
* **การสมัครสมาชิก:** ลงทะเบียนพร้อมอัปโหลดภาพโปรไฟล์ เอกสารใบอนุญาตขับขี่ และภาพถ่ายยานพาหนะเข้าสู่ระบบ Supabase
* **การรับงาน (Job Board):** ค้นหารายการคำสั่งซื้อที่อยู่ในสถานะรอผู้รับงาน และกดยอมรับงาน
* **กระบวนการจัดส่งพัสดุ (Delivery Flow):** ดูแผนที่นำทางจากจุดปัจจุบันไปยังจุดรับสินค้า และจากจุดรับไปยังจุดส่งปลายทาง สามารถอัปเดตสถานะงาน และถ่ายรูปภาพยืนยันเมื่อจัดส่งพัสดุเสร็จสิ้น
* **การส่งตำแหน่งพิกัดแบบ Real-time (Location Streaming):** ระบบจะสตรีมพิกัด GPS ของไรเดอร์ทุกๆ 1 เมตรขึ้นสู่ระบบ Firestore โดยอัตโนมัติขณะที่แอปกำลังทำงาน เพื่อให้ผู้ใช้สามารถติดตามตำแหน่งได้ทันที

---

## โครงสร้างซอร์สโค้ดในโปรเจกต์

* [lib/models/](file:///D:/Mobile/mobile_delivery/lib/models) - ไฟล์กำหนดโครงสร้างข้อมูล (Data Models) เช่น ข้อมูลผู้ใช้ ข้อมูลไรเดอร์ และข้อมูลรายการส่งของ
* [lib/providers/](file:///D:/Mobile/mobile_delivery/lib/providers) - ไฟล์จัดการสถานะของแอปพลิเคชัน เช่น [auth_provider.dart](file:///D:/Mobile/mobile_delivery/lib/providers/auth_provider.dart) สำหรับดูแลข้อมูลการเข้าสู่ระบบและการเปิดสตรีม GPS ของไรเดอร์
* [lib/repositories/](file:///D:/Mobile/mobile_delivery/lib/repositories) - บริการสื่อสารข้อมูลระหว่างแอปพลิเคชันกับเซิร์ฟเวอร์ฐานข้อมูลภายนอก
* [lib/pages/](file:///D:/Mobile/mobile_delivery/lib/pages) - ส่วนติดต่อผู้ใช้งาน (User Interface) แบ่งออกเป็น:
  * [login.dart](file:///D:/Mobile/mobile_delivery/lib/pages/login.dart) และ [chooserole.dart](file:///D:/Mobile/mobile_delivery/lib/pages/chooserole.dart) สำหรับขั้นตอนเริ่มต้นเข้าสู่แอปพลิเคชัน
  * [user_pages/](file:///D:/Mobile/mobile_delivery/lib/pages/user_pages) หน้าจอฟังก์ชันงานทั้งหมดสำหรับผู้ใช้ทั่วไป
  * [rider_pages/](file:///D:/Mobile/mobile_delivery/lib/pages/rider_pages) หน้าจอฟังก์ชันงานทั้งหมดสำหรับผู้ส่งพัสดุ
* [lib/utils/](file:///D:/Mobile/mobile_delivery/lib/utils) - ไฟล์ฟังก์ชันช่วยเหลือทั่วไป เช่น [functions.dart](file:///D:/Mobile/mobile_delivery/lib/utils/functions.dart) ในการแปลงรหัสสถานะงานส่งพัสดุ

---

## ขั้นตอนการติดตั้งและรันโปรเจกต์

### 1. การตั้งค่า Credentials
เนื่องจากตัวโปรเจกต์ไม่มีการบันทึกคีย์สำคัญลงใน Git Repository ก่อนการทดสอบรันแอปพลิเคชัน คุณจำเป็นต้องสร้างไฟล์ข้อมูลความลับไว้ในโฟลเดอร์ Root ของแอป:

สร้างไฟล์ชื่อ `secrets.json` ไว้ที่ระดับเดียวกับ [pubspec.yaml](file:///D:/Mobile/mobile_delivery/pubspec.yaml) และใส่ค่าการตั้งค่าของคุณลงไป:

```json
{
  "SUPABASE_URL": "https://<PROJECT-ID>.supabase.co",
  "SUPABASE_ANON_KEY": "<SUPABASE-ANONYMOUS-KEY>",
  "THUNDERFOREST_API_KEY": "<THUNDERFOREST-API-KEY>",
  "FIREBASE_API_KEY": "<FIREBASE-API-KEY>",
  "FIREBASE_APP_ID": "<FIREBASE-APP-ID>",
  "FIREBASE_MESSAGING_SENDER_ID": "<FIREBASE-SENDER-ID>",
  "FIREBASE_PROJECT_ID": "<FIREBASE-PROJECT-ID>",
  "FIREBASE_STORAGE_BUCKET": "<FIREBASE-STORAGE-BUCKET>"
}
```

### 2. การดาวน์โหลด dependencies
เรียกใช้งานคำสั่งใน Terminal:
```bash
flutter pub get
```

### 3. การทดสอบรันแอปพลิเคชัน
รันแอปพลิเคชันด้วยคำสั่งพร้อมอ้างอิงไฟล์ข้อมูลความลับ:
```bash
flutter run --dart-define-from-file=secrets.json
```

### 4. การคอมไพล์เพื่อใช้งานจริง (Build APK)
```bash
flutter build apk --dart-define-from-file=secrets.json
```
