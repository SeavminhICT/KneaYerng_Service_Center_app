/// Target audience selection for an admin notification campaign.
enum AdminAudience {
  all,
  registered,
  guests,
  active,
  newUsers,
  inactive,
  premium,
  custom,
}

extension AdminAudienceX on AdminAudience {
  String get label {
    switch (this) {
      case AdminAudience.all:
        return 'Everyone';
      case AdminAudience.registered:
        return 'Registered';
      case AdminAudience.guests:
        return 'Guests';
      case AdminAudience.active:
        return 'Active';
      case AdminAudience.newUsers:
        return 'New';
      case AdminAudience.inactive:
        return 'Inactive';
      case AdminAudience.premium:
        return 'Premium';
      case AdminAudience.custom:
        return 'Custom';
    }
  }

  String get apiValue {
    switch (this) {
      case AdminAudience.all:
        return 'all';
      case AdminAudience.registered:
        return 'registered';
      case AdminAudience.guests:
        return 'guests';
      case AdminAudience.active:
        return 'active';
      case AdminAudience.newUsers:
        return 'new';
      case AdminAudience.inactive:
        return 'inactive';
      case AdminAudience.premium:
        return 'premium';
      case AdminAudience.custom:
        return 'custom';
    }
  }
}
