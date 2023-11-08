import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/siri_shortcuts_api.g.dart',
    swiftOut: 'ios/Classes/SiriShortcutsApi.g.swift',
  ),
)
@HostApi()
abstract class SiriShortcutsApi {
  @async
  CreateShortcutResult createShortcut(ShortcutOptions options);
}

@FlutterApi()
abstract class SiriShortcutsFlutterApi {
  void onShortcutTriggered(ShortcutDetail detail);
}

class CreateShortcutResult {
  CreateShortcutResult(this.status, this.phrase, this.errorMessage);

  CreateShortcutStatus status;
  String? phrase;
  String? errorMessage;
}

enum CreateShortcutStatus {
  cancelled,
  added,
  deleted,
  updated,
}

class ShortcutDetail {
  ShortcutDetail(this.activityType, this.userInfo);

  final String activityType;
  final Map<String?, Object?> userInfo;
}

class ShortcutOptions {
  ShortcutOptions({
    required this.activityType,
    required this.title,
    required this.suggestedInvocationPhrase,
    this.userInfo,
    this.eligibility,
    this.description,
    this.requiredUserInfoKeys,
    this.needsSave,
    this.webpageURL,
    this.referrerURL,
    this.expirationDate,
    this.keywords,
    this.persistentIdentifier,
    this.contentType,
  });

  /// The activity type associated with the shortcut.
  final String activityType;

  /// The user-visible title for the shortcut.
  final String title;

  /// A human-understandable string that can be used to suggest a voice shortcut phrase to the user.
  final String? suggestedInvocationPhrase;

  /// A map containing app-specific state information needed to continue an activity on another device.
  final Map<String?, Object?>? userInfo;

  /// The eligibility for the shortcut.
  final ShortcutEligibility? eligibility;

  /// A description for the shortcut.
  final String? description;

  /// The keys from the userInfo property which represent the minimal information
  /// about the shortcut that should be stored for later restoration.
  ///
  /// A null value means all keys are required.
  final List<String?>? requiredUserInfoKeys;

  /// Indicates that the state of the activity needs to be updated.
  final bool? needsSave;

  /// When no suitable application is installed on a resuming device and the webpageURL is set,
  /// the shortcut will instead be continued in a web browser by loading this resource.
  final String? webpageURL;

  /// The URL of the webpage that referred (linked to) [webpageURL].
  final String? referrerURL;

  /// If non-null, then an absolute date after which
  /// the shortcut is no longer eligible to be indexed or handed off.
  final int? expirationDate;

  /// A set of keywords, representing words or phrases in the current user's language
  /// that might help the user to find the shortcut in the application history.
  final List<String?>? keywords;

  /// A value used to identify the shortcut.
  final String? persistentIdentifier;

  /// The content type of the shortcut's attribute set.
  final String? contentType;
}

class ShortcutEligibility {
  const ShortcutEligibility({
    this.search = true,
    this.prediction = true,
    this.handOff = false,
    this.publicIndexing = false,
  });

  /// Set to true if the shortcut should be indexed by App History.
  final bool search;

  /// Set to true if Siri should suggest the shortcut to users.
  final bool prediction;

  /// Set to true if the shortcut should be eligible to be handed off to another device.
  final bool handOff;

  /// Set to true if the shortcut should be eligible for indexing for any user of this application,
  /// on any device, or false if the activity contains private or sensitive information or
  /// which would not be useful to other users if indexed.
  ///
  /// The activity must also have [ShortcutOptions.requiredUserActivityKeys]
  /// or a [ShortcutOptions.webpageURL].
  final bool publicIndexing;
}
