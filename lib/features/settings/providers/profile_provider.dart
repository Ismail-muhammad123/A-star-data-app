import 'package:app/features/settings/data/models/profile_model.dart';
import 'package:app/features/settings/data/repositories/profile_repo.dart';
import 'package:flutter/widgets.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  UserProfile? profile;
  loadProfile(String authToken) async {
    var prof = await _profileService.fetchUserProfile(authToken);
    if (prof != null) {
      profile = prof;
    }
    notifyListeners();
  }
}
