class SettingsModel {
  bool autoLightsOff;
  bool autoCurtainClose;
  bool lightsOnWake;
  bool curtainOpenWake;

  SettingsModel({
    this.autoLightsOff = true,
    this.autoCurtainClose = true,
    this.lightsOnWake = true,
    this.curtainOpenWake = true,
  });

  Map<String, dynamic> toMap() => {
    'autoLightsOff': autoLightsOff,
    'autoCurtainClose': autoCurtainClose,
    'lightsOnWake': lightsOnWake,
    'curtainOpenWake': curtainOpenWake,
  };

  factory SettingsModel.fromMap(Map<String, dynamic> map) => SettingsModel(
    autoLightsOff: map['autoLightsOff'] ?? true,
    autoCurtainClose: map['autoCurtainClose'] ?? true,
    lightsOnWake: map['lightsOnWake'] ?? true,
    curtainOpenWake: map['curtainOpenWake'] ?? true,
  );
}
