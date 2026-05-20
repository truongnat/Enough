enum StopSessionStatus {
  active,
  completed,
  snoozed,
  missed;

  bool get isActive => this == StopSessionStatus.active;
  bool get isCompleted => this == StopSessionStatus.completed;
  bool get isSnoozed => this == StopSessionStatus.snoozed;
  bool get isMissed => this == StopSessionStatus.missed;
}
