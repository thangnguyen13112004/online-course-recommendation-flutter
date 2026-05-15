abstract class SettingsEvent {}

class LoadSettingsEvent extends SettingsEvent {}

class TogglePushNotificationEvent extends SettingsEvent {
  final bool value;
  TogglePushNotificationEvent(this.value);
}

class ToggleEmailNotificationEvent extends SettingsEvent {
  final bool value;
  ToggleEmailNotificationEvent(this.value);
}

class ToggleDarkModeEvent extends SettingsEvent {
  final bool value;
  ToggleDarkModeEvent(this.value);
}

class DeactivateAccountEvent extends SettingsEvent {}
