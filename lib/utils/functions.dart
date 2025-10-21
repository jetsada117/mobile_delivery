String statusLabel(int s) {
  switch (s) {
    case 1:
      return '[1] รอไรเดอร์มารับสินค้า';
    case 2:
      return '[2] ไรเดอร์รับงาน';
    case 3:
      return '[3] ไรเดอร์รับสินค้าแล้วและกำลังเดินทางไปส่ง';
    case 4:
      return '[4] ไรเดอร์นำส่งสินค้าแล้ว';
    default:
      return '[0] สร้างคำสั่งซื้อ';
  }
}
