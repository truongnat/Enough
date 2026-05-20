import 'stop_type.dart';

class StopProtocol {
  final String id;
  final StopType stopType;
  final String title;
  final List<String> steps;

  StopProtocol({
    required this.id,
    required this.stopType,
    required this.title,
    required this.steps,
  });

  static List<StopProtocol> getTemplatesFor(StopType type) {
    switch (type) {
      case StopType.coding:
        return [
          StopProtocol(
            id: 'proto_coding_standard',
            stopType: StopType.coding,
            title: 'Stop Coding Standard Protocol',
            steps: [
              'Save hoặc stash code hiện tại',
              'Ghi lại việc cần làm tiếp theo',
              'Đóng IDE / Tắt màn hình ngoài',
              'Rời khỏi bàn làm việc ít nhất 2 phút'
            ],
          ),
          StopProtocol(
            id: 'proto_coding_aggressive',
            stopType: StopType.coding,
            title: 'Stop Coding Hardcore Protocol',
            steps: [
              'Đóng ngay lập tức toàn bộ cửa sổ terminal/IDE',
              'Đứng dậy kéo giãn cơ và đốt ngón tay',
              'Uống 1 cốc nước ấm đầy',
              'Tắt nguồn máy tính và đi nằm'
            ],
          )
        ];
      case StopType.working:
        return [
          StopProtocol(
            id: 'proto_working_standard',
            stopType: StopType.working,
            title: 'Stop Working Protocol',
            steps: [
              'Tắt Slack / Teams / Mail thông báo công việc',
              'Sắp xếp bàn làm việc ngăn nắp',
              'Đóng laptop hoặc bấm tắt màn hình',
              'Tự nhủ công ty sẽ ổn trong 12 tiếng tới'
            ],
          )
        ];
      case StopType.scrolling:
        return [
          StopProtocol(
            id: 'proto_scrolling_standard',
            stopType: StopType.scrolling,
            title: 'Stop Scrolling Protocol',
            steps: [
              'Nhắm mắt chặt trong 10 giây',
              'Nhìn ra xa khoảng 6 mét trong 20 giây',
              'Úp màn hình điện thoại xuống bàn',
              'Rời phòng hoặc uống 1 ngụm nước lớn'
            ],
          )
        ];
      case StopType.overthinking:
        return [
          StopProtocol(
            id: 'proto_overthinking_standard',
            stopType: StopType.overthinking,
            title: 'Stop Overthinking Protocol',
            steps: [
              'Viết 3 suy nghĩ đang bận tâm ra giấy',
              'Thở sâu bằng bụng 5 nhịp chậm rãi',
              'Đứng dậy thay đổi không gian (qua phòng khác)',
              'Uống 1 cốc nước ấm hoặc rửa mặt nước mát'
            ],
          )
        ];
      case StopType.sleep:
        return [
          StopProtocol(
            id: 'proto_sleep_standard',
            stopType: StopType.sleep,
            title: 'Go Sleep Protocol',
            steps: [
              'Đặt điện thoại ra xa tầm giường ngủ (> 2 mét)',
              'Tắt tất cả thiết bị phát sáng trong phòng',
              'Nằm ngửa thả lỏng toàn bộ cơ mặt',
              'Bắt đầu đếm nhịp thở từ 1 đến 100'
            ],
          )
        ];
      case StopType.custom:
        return [
          StopProtocol(
            id: 'proto_custom_default',
            stopType: StopType.custom,
            title: 'Default Stop Protocol',
            steps: [
              'Dừng việc đang làm lại ngay',
              'Hít thở thật sâu 3 hơi',
              'Di chuyển ra vị trí khác',
              'Nghỉ ngơi đầu óc'
            ],
          )
        ];
    }
  }

  static StopProtocol getDefaultTemplate(StopType type) {
    return getTemplatesFor(type).first;
  }
}
