const baseUrl = "https://backend.stardata.com.ng/api";
// const baseUrl = "https://0663225b3ddb.ngrok-free.app/api";
// const baseUrl = "https://a-star-backend-staging.up.railway.app/api";

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

  // 2FA & FCM
  final String verify2FA = "$baseUrl/account/verify-2fa/";
  final String twoFaResend = "$baseUrl/account/2fa/resend/";
  final String twoFaReset = "$baseUrl/account/2fa/reset/";
  final String twoFaSettings = "$baseUrl/account/2fa/settings/";
  final String registerFCM = "$baseUrl/account/device/register-fcm-token/";
}

class ProfileEndpoints {
  final String getProfile = "$baseUrl/account/profile/";
  final String updateProfile = "$baseUrl/account/profile/";
  final String changePin = "$baseUrl/account/change-pin/";

  final String bankInfoSubmit = "$baseUrl/account/bank-details/create/";
  final String bankInfoUpdate = "$baseUrl/account/bank-details/update/";
  final String bankInfoRetrive = "$baseUrl/account/bank-details/";
}

class WalletEndpoints {
  final String getWallet = "$baseUrl/wallet/";
  final String getVirtualAccount = "$baseUrl/wallet/virtual-account/";
  final String createVirtualAccount =
      "$baseUrl/account/generate-virtual-account/";
  final String fundWallet = "$baseUrl/wallet/deposit/";
  final String walletTransactions = "$baseUrl/wallet/transactions/";
  final String withdraw = "$baseUrl/wallet/withdraw-to-bank/";
  final String banks = "$baseUrl/wallet/banks/";
  final String resolveAccount = "$baseUrl/wallet/resolve-account/";
  final String withdrawalAccount = "$baseUrl/wallet/withdrawal-account/";
  final String chargesConfig = "$baseUrl/payment/charges-config/";

  // NEW: P2P inside Wallet
  final String lookupUser = "$baseUrl/wallet/lookup-user/";
  final String p2pTransfer = "$baseUrl/wallet/p2p-transfer/";
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

  final String getInternetServices = "$baseUrl/orders/internet-services/";
  final String getInternetPackages = "$baseUrl/orders/internet-packages/";
  String getInternetPackagesByService(int networkId) =>
      "$baseUrl/orders/internet-services/$networkId/packages/";
  final String purchaseInternetSubscription =
      "$baseUrl/orders/buy-internet-subscription/";

  final String getEducationServices = "$baseUrl/orders/education-services/";
  final String getEducationPackages = "$baseUrl/orders/education-packages/";
  final String purchaseEducation = "$baseUrl/orders/buy-education/";

  final String orderHistory = "$baseUrl/orders/purchase-history/";
}

// ---- NEW FEATURE CLASSES ----

class TransactionPinEndpoints {
  final String setPin = "$baseUrl/account/set-transaction-pin/";
  final String changePin = "$baseUrl/account/change-transaction-pin/";
  final String verifyPin = "$baseUrl/account/verify-transaction-pin/";
  final String requestResetOtp =
      "$baseUrl/account/request-transaction-pin-reset-otp/";
  final String resetPin = "$baseUrl/account/reset-transaction-pin/";
}

class SupportEndpoints {
  final String support = "$baseUrl/support/";
  String messages(int id) => "$baseUrl/support/$id/messages/";
  String closeTicket(int id) => "$baseUrl/support/$id/close/";
}

class NotificationEndpoints {
  final String list = "$baseUrl/account/notifications/";
  final String announcements = "$baseUrl/account/announcements/";
  String markRead(int id) => "$baseUrl/account/notifications/$id/mark-as-read/";
  final String markAllRead = "$baseUrl/account/notifications/mark-all-as-read/";
}

class KycEndpoints {
  final String status = "$baseUrl/account/kyc/";
  final String submit = "$baseUrl/account/kyc/";
}

class ReferralEndpoints {
  final String info = "$baseUrl/account/referral/";
}

class BeneficiaryEndpoints {
  final String purchaseBeneficiaries = "$baseUrl/orders/beneficiaries/";
  final String walletBeneficiaries = "$baseUrl/wallet/beneficiaries/";
  
  String deletePurchaseBeneficiary(int id) =>
      "$baseUrl/orders/beneficiaries/$id/";
      
  String deleteWalletBeneficiary(int id) =>
      "$baseUrl/wallet/beneficiaries/$id/";
}

class AccountUpgradeEndpoints {
  final String fees = "$baseUrl/account/upgrade/fees/";
  final String upgrade = "$baseUrl/account/upgrade/";
  final String upgradeAgent = "$baseUrl/account/upgrade/agent/";
}

class P2PEndpoints {
  final String lookup = "$baseUrl/wallet/p2p-verify/";
  final String transfer = "$baseUrl/wallet/transfer-p2p/";
}
