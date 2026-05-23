# Enough — Product Spec v1

Enough là ứng dụng Reverse Alarm: báo thức để dừng lại, không phải để bắt đầu.

Mục tiêu:
Giúp người dùng dừng đúng lúc các hành vi dễ bị cuốn như coding quá muộn, làm việc ngoài giờ, doom scrolling, overthinking, chơi game lâu hoặc thức khuya.

Ứng dụng local-first:
- Không auth
- Không backend
- Không cloud sync
- Dữ liệu lưu local
- Có thể export/import JSON sau
A. Home Screen
Mục tiêu:
Home là dashboard chính, giúp user biết alarm tiếp theo là gì và hôm nay đã dừng được những gì.

Yêu cầu UI:

1. Header
- Hiển thị greeting:
  “Chào buổi sáng/chiều/tối, {userName} 👋”
- Bên phải có icon đổi theme sáng/tối.
- Nếu chưa có userName thì dùng fallback:
  “Chào buổi tối 👋”

2. Main title
Text:
“Hôm nay bạn muốn
dừng điều gì?”

3. Next Stop Alarm card
Section label:
“Tiếp theo”

Hiển thị Stop Alarm gần nhất sắp trigger:
- Tên alarm / stop type
- Giờ thông báo
- Countdown còn lại
- Mode: General / Strict
- Trạng thái: Hoạt động / Không hoạt động

Nếu chưa có alarm:
- Không show nhiều CTA.
- Show một empty state duy nhất:
  “Chưa có báo thức dừng nào”
  CTA: “Tạo Stop Alarm đầu tiên”

4. Today stopped section
Section header:
- Left: “Đã dừng hôm nay”
- Right: icon xem tất cả

Right icon dẫn tới History/List sessions.

Hiển thị các card Stop Session đã được trigger hôm nay:
- Tên event/alarm
- Thời gian thông báo
- Trạng thái: Thành công / Snooze / Chưa xác nhận
- Tối đa 3 item trên Home
- Nếu nhiều hơn thì có “Xem tất cả”

5. All Stop Alarms
Home vẫn cần chỗ xem toàn bộ Stop Alarm đã tạo:
- Có thể hiển thị compact list dưới Next Alarm
- Hoặc đưa sang màn List Alarm riêng
- Không nhầm với History

Rule:
- Next Alarm chỉ hiển thị alarm gần nhất.
- All Stop Alarms hiển thị toàn bộ alarm.
- History hiển thị các session đã trigger.
B. History Screen
Mục tiêu:
History hiển thị các Stop Session đã được thông báo/trigger, không phải danh sách alarm cấu hình.

Tabs:
1. Tất cả
2. Thành công
3. Snooze

Mỗi event/session hiển thị:
- Tên event / Stop Alarm title
- Thời gian thông báo
- Trạng thái:
  - Thành công
  - Snooze
  - Chưa xác nhận / Missed nếu cần
- Mode: General / Strict nếu cần

Khi click vào event:
- Mở Stop Session Detail
- Nếu có Stop Receipt thì hiển thị receipt
- Nếu chưa hoàn thành thì hiển thị trạng thái session và action phù hợp

Data source:
- StopSessionRepository
- StopReceiptRepository
C. Add/Edit Stop Alarm Screen
Mục tiêu:
User tạo cấu hình Stop Alarm mới.

Fields:

1. Tên event
- Text input
- Placeholder:
  “Ví dụ: Stop Coding, Stop Scrolling...”
- Nếu để trống, auto generate theo stop type.

2. Bạn muốn dừng điều gì?
Hiển thị option cards:
- Stop Coding
- Stop Working
- Stop Scrolling
- Stop Overthinking
- Go Sleep
- Custom

3. Thời gian thông báo
- Gồm giờ và phút.
- Khi bấm vào giờ hoặc phút, mở bottom sheet dạng wheel picker để user vuốt.
- Không dùng time picker mặc định nếu UI không hợp concept.
- Format: HH:mm.

4. Trạng thái
- Hoạt động
- Không hoạt động

Nếu không hoạt động:
- Alarm vẫn lưu local
- Không schedule notification

5. Lặp lại
Preset options:
- Hàng ngày
- Ngày thường
- Cuối tuần
- Không lặp lại

Bên dưới có custom weekdays:
- T2
- T3
- T4
- T5
- T6
- T7
- CN

Rules:
- Hàng ngày = chọn tất cả 7 ngày
- Ngày thường = T2-T6
- Cuối tuần = T7-CN
- Không lặp lại = repeatDays rỗng
- Nếu user tự chọn ngày, preset chuyển về custom

6. Chế độ
Có 2 mode chính:
- General
- Strict

General:
- Đến giờ thì gửi notification.
- Nếu app đang mở thì có thể hiện modal nhẹ.
- Không bắt buộc user xác nhận.
- Session được ghi nhận là notified/general.

Strict:
- Đến giờ thì gửi notification với âm thanh/rung.
- Nếu app đang mở thì hiện modal bắt xác nhận.
- User phải bấm “Tôi đã dừng lại” hoặc “Snooze”.
- Nếu chưa xác nhận, app nhắc lại mỗi 1 phút theo best-effort.
- Foreground có thể rung/chuông liên tục.
- Background/killed dùng notification scheduling best-effort, không cam kết y như system alarm trên mọi OS.

7. Tin nhắn
- Optional text input.
- Nếu user nhập, notification body dùng message này.
- Nếu user không nhập, dùng generic message theo stop type/mode.

Ví dụ:
Stop Coding:
“Mày không phải server chạy 24/7. Dừng lại thôi.”

Stop Scrolling:
“Không có video thứ 87 nào cứu đời mày đâu.”

8. Save
Button:
“Lưu Stop Alarm”

Khi save:
- Validate input
- Save local
- Schedule notification nếu trạng thái Hoạt động
- Refresh Home/List Alarm
- Quay về màn trước
D. Stats Screen
Mục tiêu:
Thống kê hành vi dừng trong tuần.

Metrics:

1. Thống kê tuần
- Lần đã dừng
- Tỷ lệ thành công
- Tỷ lệ thất bại / missed
- Tỷ lệ snooze
- Năng lượng bảo vệ

Definition:
- Lần đã dừng = số session completed trong tuần
- Tỷ lệ thành công = completed / total triggered sessions
- Tỷ lệ thất bại = missed / total triggered sessions
- Tỷ lệ snooze = sessions có snoozeCount > 0 / total sessions
- Năng lượng bảo vệ = thời gian từ lúc user xác nhận dừng so với một baseline
  MVP có thể tính đơn giản:
  completedSessions * 30 phút
  hoặc
  scheduledAt -> completedAt nếu có data hợp lý

2. Nhịp dừng trong tuần
- Biểu đồ cột
- Trục X: T2-CN
- Trục Y: số lần dừng
- Dựa trên completed Stop Sessions
E. Settings Screen
Sections:

1. Giao diện và cấu hình
- Chọn chủ đề:
  - Sáng
  - Tối
  - Theo hệ thống
- Chế độ mặc định:
  - General
  - Strict
- Thời gian báo lại:
  - 1 phút
  - 5 phút
  - 10 phút
  - 15 phút

2. Dữ liệu
- Export dữ liệu JSON
- Import dữ liệu JSON
- Xóa dữ liệu

3. Pháp lý
- Chính sách quyền riêng tư
- Điều khoản sử dụng nếu cần

4. Ứng dụng
- Phiên bản
- Build number