const baseUrl = "https://backend.stardata.com.ng/api";
// const baseUrl = "https://0663225b3ddb.ngrok-free.app/api";

// AUTH
class AuthEndpoints {
  final String register = "$baseUrl/account/signup/";
  final String login = "$baseUrl/account/login/";
  final String refresh = "$baseUrl/account/refresh-token/";
  final String logout = "$baseUrl/account/logout";
  final String resetPin = "$baseUrl/account/reset-password/";
  final String resendConfirmationOTP =
      "$baseUrl/account/resend-activation-code/";
  final String activateAccount = "$baseUrl/account/activate-account/";
  final String confirmPinReset = "$baseUrl/account/confirm-reset-password/";
  final String closeAccount = "$baseUrl/account/close-account/";
}

class ProfileEndpoints {
  final String getProfile = "$baseUrl/account/profile/";
  final String updateProfile = "$baseUrl/account/profile/";
  final String changePin = "$baseUrl/account/change-pin/";
  final String upgradeAccountTier = "$baseUrl/account/upgrade-account/";

  final String bankInfoSubmit = "$baseUrl/account/bank-details/create/";
  final String bankInfoUpdate = "$baseUrl/account/bank-details/update/";
  final String bankInfoRetrive = "$baseUrl/account/bank-details/";
  // final String getNigerianBanks = "$baseUrl/account/list-nigerian-banks";
}

class WalletEndpoints {
  final String getWallet = "$baseUrl/wallet/";
  final String getVirtualAccount = "$baseUrl/wallet/virtual-account/";
  final String fundWallet = "$baseUrl/wallet/deposit/";
  final String walletTransactions = "$baseUrl/wallet/transactions/";
  final String withdraw = "$baseUrl/payment/withdrawal-request/";
  final String banks = "$baseUrl/wallet/banks/";
  final String resolveAccount = "$baseUrl/wallet/resolve-account/";
  final String withdrawalAccount = "$baseUrl/wallet/withdrawal-account/";
}

class OrderEndpoints {
  final String getDataNetworks = "$baseUrl/orders/data-networks/";
  final String getDataBundles = "$baseUrl/orders/data-plans/";
  final String getSmilePackages = "$baseUrl/orders/smile-packages/";
  final String purchaseDataBundle = "$baseUrl/orders/buy-data/";
  final String purchaseSmileSubscription =
      "$baseUrl/orders/buy-smile-subscription/";

  final String getAirtimeNetworks = "$baseUrl/orders/airtime-networks/";
  final String purchaseAirtime = "$baseUrl/orders/buy-airtime/";

  final String verifyCustomer = "$baseUrl/orders/verify-customer/";

  final String getTVServices = "$baseUrl/orders/tv-services/";
  final String getTVPackages = "$baseUrl/orders/tv-packages/";
  final String purchaseTVSubscription = "$baseUrl/orders/buy-tv-subscription/";

  final String getElectricityServices = "$baseUrl/orders/electricity-services/";
  final String purchaseElectricity = "$baseUrl/orders/buy-electricity/";

  final String orderHistory = "$baseUrl/orders/purchase-history/";
}
