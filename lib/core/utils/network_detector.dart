/// Detects the Nigerian mobile network name from a phone number prefix.
///
/// Returns one of: 'mtn', 'glo', 'airtel', '9mobile' — or null if unknown.
String? detectNigerianNetwork(String phone) {
  // Normalise: strip leading +234 or 234 to get 0XXXXXXXXX
  String number = phone.trim();
  if (number.startsWith('+234')) {
    number = '0${number.substring(4)}';
  } else if (number.startsWith('234') && number.length == 13) {
    number = '0${number.substring(3)}';
  }

  if (number.length < 4) return null;

  final prefix = number.substring(0, 4);

  const mtn = {
    '0803', '0806', '0810', '0813', '0814', '0816',
    '0903', '0906', '0703', '0704', '0706',
  };
  const glo = {
    '0805', '0807', '0811', '0815', '0905', '0705',
  };
  const airtel = {
    '0802', '0808', '0812', '0902', '0907', '0901', '0708', '0701',
  };
  const mobile9 = {
    '0809', '0817', '0818', '0909', '0908',
  };

  if (mtn.contains(prefix)) return 'mtn';
  if (glo.contains(prefix)) return 'glo';
  if (airtel.contains(prefix)) return 'airtel';
  if (mobile9.contains(prefix)) return '9mobile';

  return null;
}

/// Given a detected network key (e.g. 'mtn') and a list of network objects
/// with a [serviceName] field, returns the id of the first network whose
/// serviceName contains the key (case-insensitive). Returns null if no match.
int? matchNetworkId<T>({
  required String? detectedKey,
  required List<T> networks,
  required String Function(T) serviceName,
  required int Function(T) id,
}) {
  if (detectedKey == null) return null;
  final key = detectedKey.toLowerCase();
  for (final network in networks) {
    if (serviceName(network).toLowerCase().contains(key)) {
      return id(network);
    }
  }
  return null;
}
