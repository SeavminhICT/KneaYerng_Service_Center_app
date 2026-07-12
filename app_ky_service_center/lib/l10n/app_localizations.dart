import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this._locale);
  final Locale _locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(Locale('en'));
  }

  static const delegate = _AppLocalizationsDelegate();

  bool get isKhmer => _locale.languageCode == 'km';
  String _t(String en, String km) => isKhmer ? km : en;

  // ── Navigation ────────────────────────────────────────────────────────────
  String get home      => _t('Home',      'ទំព័រដើម');
  String get repair    => _t('Repair',    'ជួសជុល');
  String get orders    => _t('Orders',    'ការបញ្ជាទិញ');
  String get favorites => _t('Favorites', 'ចូលចិត្ត');
  String get profile   => _t('Profile',   'គណនី');

  // ── Common ────────────────────────────────────────────────────────────────
  String get save           => _t('Save',              'រក្សាទុក');
  String get cancel         => _t('Cancel',            'បោះបង់');
  String get back           => _t('Back',              'ត្រឡប់');
  String get confirm        => _t('Confirm',           'បញ្ជាក់');
  String get next           => _t('Next',              'បន្ទាប់');
  String get skip           => _t('Skip',              'រំលង');
  String get done           => _t('Done',              'រួចរាល់');
  String get search         => _t('Search',            'ស្វែងរក');
  String get seeAll         => _t('See All',           'មើលទាំងអស់');
  String get loading        => _t('Loading...',        'កំពុងផ្ទុក...');
  String get retry          => _t('Retry',             'ព្យាយាមម្ដងទៀត');
  String get ok             => _t('OK',                'យល់ព្រម');
  String get yes            => _t('Yes',               'បាទ/ចាស');
  String get no             => _t('No',                'ទេ');
  String get getStarted     => _t('Get Started',       'ចាប់ផ្ដើម');
  String get continueText   => _t('Continue',          'បន្ត');
  String get edit           => _t('Edit',              'កែប្រែ');
  String get delete         => _t('Delete',            'លុប');
  String get viewAll        => _t('View All',          'មើលទាំងអស់');
  String get remove         => _t('Remove',            'ដកចេញ');
  String get support        => _t('Support',           'ជំនួយ');
  String get add            => _t('Add',               'បន្ថែម');
  String get close          => _t('Close',             'បិទ');
  String get apply          => _t('Apply',             'អនុវត្ត');
  String get clear          => _t('Clear',             'សម្អាត');

  // ── Auth ──────────────────────────────────────────────────────────────────
  String get login               => _t('Login',                    'ចូល');
  String get register            => _t('Register',                 'ចុះឈ្មោះ');
  String get email               => _t('Email',                    'អ៊ីមែល');
  String get password            => _t('Password',                 'ពាក្យសម្ងាត់');
  String get phoneNumber         => _t('Phone Number',             'លេខទូរស័ព្ទ');
  String get fullName            => _t('Full Name',                'ឈ្មោះពេញ');
  String get signIn              => _t('Sign In',                  'ចូលគណនី');
  String get signUp              => _t('Sign Up',                  'បង្កើតគណនី');
  String get forgotPassword      => _t('Forgot Password?',         'ភ្លេចពាក្យសម្ងាត់?');
  String get alreadyHaveAccount  => _t('Already have an account?', 'មានគណនីហើយ?');
  String get dontHaveAccount     => _t("Don't have an account?",   'មិនទាន់មានគណនី?');
  String get confirmPassword     => _t('Confirm Password',         'បញ្ជាក់ពាក្យសម្ងាត់');
  String get welcomeBack         => _t('Welcome Back',             'សូមស្វាគមន៍មកវិញ');
  String get createAccount       => _t('Create Account',           'បង្កើតគណនី');
  String get otpVerification     => _t('OTP Verification',         'ការផ្ទៀងផ្ទាត់ OTP');
  String get enterOtp            => _t('Enter OTP',                'បញ្ចូល OTP');
  String get resend              => _t('Resend',                   'ផ្ញើម្ដងទៀត');
  String get logout              => _t('Logout',                   'ចាកចេញ');
  String get logoutConfirm       => _t('Are you sure you want to logout?', 'តើអ្នកពិតជាចង់ចាកចេញ?');
  String get sendResetLink       => _t('Send Reset Link',          'ផ្ញើតំណភ្ជាប់កំណត់ឡើងវិញ');
  String get resetPassword       => _t('Reset Password',           'កំណត់ពាក្យសម្ងាត់ឡើងវិញ');
  String get newPassword         => _t('New Password',             'ពាក្យសម្ងាត់ថ្មី');
  String get verifyOtp           => _t('Verify',                   'ផ្ទៀងផ្ទាត់');
  String get registrationSuccess => _t('Registration Successful',  'ការចុះឈ្មោះបានជោគជ័យ');
  String get registrationSuccessMessage => _t(
    'Your account is verified. Start exploring services and managing your bookings.',
    'គណនីរបស់អ្នកត្រូវបានផ្ទៀងផ្ទាត់រួចរាល់។ អ្នកអាចចាប់ផ្តើមប្រើសេវាកម្ម និងគ្រប់គ្រងការកក់បានឥឡូវនេះ។',
  );

  // ── Home ──────────────────────────────────────────────────────────────────
  String get searchProducts   => _t('Search products...',        'ស្វែងរកផលិតផល...');
  String get categories       => _t('Categories',               'ប្រភេទ');
  String get hotSale          => _t('Hot Sale',                 'ពិសេសប្រចាំថ្ងៃ');
  String get featuredProducts => _t('Featured Products',        'ផលិតផលពិសេស');
  String get popularProducts  => _t('Popular Products',         'ផលិតផលពេញនិយម');
  String get newArrivals      => _t('New Arrivals',             'ទំនិញថ្មី');
  String get allProducts      => _t('All Products',             'ផលិតផលទាំងអស់');
  String get helloUser        => _t('Hello',                    'សួស្ដី');
  String get goodMorning      => _t('Good Morning',             'អរុណសួស្ដី');
  String get goodAfternoon    => _t('Good Afternoon',           'ទិវាសួស្ដី');
  String get goodEvening      => _t('Good Evening',             'សាយណ្ហសួស្ដី');

  // ── Cart ──────────────────────────────────────────────────────────────────
  String get cart           => _t('Cart',              'កន្ត្រក');
  String get checkout       => _t('Checkout',          'ទូទាត់');
  String get addToCart      => _t('Add to Cart',       'បន្ថែមទៅកន្ត្រក');
  String get buyNow         => _t('Buy Now',           'ទិញឥឡូវ');
  String get subtotal       => _t('Subtotal',          'តម្លៃរង');
  String get total          => _t('Total',             'សរុប');
  String get deliveryFee    => _t('Delivery Fee',      'ថ្លៃដឹកជញ្ជូន');
  String get orderSummary   => _t('Order Summary',     'សង្ខេបការបញ្ជាទិញ');
  String get emptyCart      => _t('Your cart is empty','កន្ត្រករបស់អ្នកទទេ');
  String get placeOrder     => _t('Place Order',       'ដាក់ការបញ្ជាទិញ');
  String get quantity       => _t('Quantity',          'បរិមាណ');
  String get payment        => _t('Payment',           'ការទូទាត់');
  String get payNow         => _t('Pay Now',           'ទូទាត់ឥឡូវ');

  // ── Orders ────────────────────────────────────────────────────────────────
  String get myOrders    => _t('My Orders',    'ការបញ្ជាទិញរបស់ខ្ញុំ');
  String get orderStatus => _t('Order Status', 'ស្ថានភាព');
  String get pending     => _t('Pending',      'កំពុងរង់ចាំ');
  String get confirmed   => _t('Confirmed',    'បានបញ្ជាក់');
  String get processing  => _t('Processing',   'កំពុងដំណើរការ');
  String get shipped     => _t('Shipped',      'បានដឹក');
  String get delivered   => _t('Delivered',    'បានដល់');
  String get cancelled   => _t('Cancelled',    'បានបោះបង់');
  String get trackOrder  => _t('Track Order',  'តាមដានការបញ្ជាទិញ');
  String get orderHistory=> _t('Order History','ប្រវត្តិការបញ្ជាទិញ');
  String get noOrders    => _t('No orders yet','មិនទាន់មានការបញ្ជាទិញ');

  // ── Profile ───────────────────────────────────────────────────────────────
  String get myProfile        => _t('My Profile',            'ប្រវត្តិរូបខ្ញុំ');
  String get editProfile      => _t('Edit Profile',          'កែប្រែប្រវត្តិរូប');
  String get language         => _t('Language',              'ភាសា');
  String get darkMode         => _t('Dark Mode',             'របៀបងងឹត');
  String get notifications    => _t('Notifications',         'ការជូនដំណឹង');
  String get privacy          => _t('Privacy',               'ភាពឯកជន');
  String get supportChat      => _t('Support Chat',          'ជជែកជំនួយ');
  String get helpCenter       => _t('Help Center',           'មជ្ឈមណ្ឌលជំនួយ');
  String get settings         => _t('Settings',              'ការកំណត់');
  String get version          => _t('Version',               'កំណែ');
  String get personalInfo     => _t('Personal Information',  'ព័ត៌មានផ្ទាល់ខ្លួន');
  String get address          => _t('Address',               'អាសយដ្ឋាន');
  String get savedAddresses   => _t('Saved Addresses',       'អាសយដ្ឋានដែលបានរក្សា');
  String get adminPanel       => _t('Admin Panel',           'ផ្ទាំងរដ្ឋបាល');
  String get reviews          => _t('Reviews',               'មតិ');

  // ── Language picker ───────────────────────────────────────────────────────
  String get selectLanguage   => _t('Select Language',       'ជ្រើសរើសភាសា');
  String get changeLanguage   => _t('Change Language',       'ប្ដូរភាសា');
  String get english          => _t('English',               'ភាសាអង់គ្លេស');
  String get khmer            => _t('Khmer',                 'ភាសាខ្មែរ');
  String get languageSaved    => _t('Language updated',      'ភាសាបានផ្លាស់ប្ដូរ');

  // ── Categories / Products ─────────────────────────────────────────────────
  String get filter              => _t('Filter',                   'ត្រង');
  String get sort                => _t('Sort',                     'តម្រៀប');
  String get inStock             => _t('In Stock',                 'មានស្តុក');
  String get outOfStock          => _t('Out of Stock',             'អស់ស្តុក');
  String get addToFavorites      => _t('Add to Favorites',         'បន្ថែមទៅចំណូលចិត្ត');
  String get removeFromFavorites => _t('Remove from Favorites',    'ដកចេញពីចំណូលចិត្ត');
  String get productDetails      => _t('Product Details',          'ព័ត៌មានផលិតផល');
  String get relatedProducts     => _t('Related Products',         'ផលិតផលពាក់ព័ន្ធ');
  String get price               => _t('Price',                    'តម្លៃ');
  String get description         => _t('Description',              'ការពិពណ៌នា');

  // ── Repair ────────────────────────────────────────────────────────────────
  String get repairService   => _t('Repair Service',    'សេវាជួសជុល');
  String get repairRequest   => _t('Repair Request',    'សំណើជួសជុល');
  String get deviceType      => _t('Device Type',       'ប្រភេទឧបករណ៍');
  String get issueDesc       => _t('Issue Description', 'ការពណ៌នាបញ្ហា');
  String get submitRequest   => _t('Submit Request',    'ដាក់សំណើ');
  String get myTickets       => _t('My Tickets',        'សំបុត្ររបស់ខ្ញុំ');

  // ── Favorites ─────────────────────────────────────────────────────────────
  String get myFavorites  => _t('My Favorites',      'ចំណូលចិត្តរបស់ខ្ញុំ');
  String get noFavorites  => _t('No favorites yet',  'មិនទាន់មានចំណូលចិត្ត');

  // ── Notifications ─────────────────────────────────────────────────────────
  String get noNotifications => _t('No notifications yet', 'មិនទាន់មានការជូនដំណឹង');
  String get markAllRead     => _t('Mark all as read',     'សម្គាល់ទាំងអស់ថាបានអាន');

  // ── Delivery ──────────────────────────────────────────────────────────────
  String get deliveryAddress   => _t('Delivery Address',    'អាសយដ្ឋានដឹកជញ្ជូន');
  String get selectAddress     => _t('Select Address',      'ជ្រើសរើសអាសយដ្ឋាន');
  String get addNewAddress     => _t('Add New Address',     'បន្ថែមអាសយដ្ឋានថ្មី');
  String get deliveryTracking  => _t('Delivery Tracking',   'តាមដានការដឹកជញ្ជូន');

  // ── Errors / Feedback ─────────────────────────────────────────────────────
  String get noInternetConnection => _t('No internet connection',  'គ្មានការតភ្ជាប់អ៊ីនធឺណិត');
  String get somethingWentWrong   => _t('Something went wrong',    'មានបញ្ហាកើតឡើង');
  String get successfullySaved    => _t('Successfully saved',      'បានរក្សាទុកដោយជោគជ័យ');
  String get passwordsDoNotMatch  => _t('Passwords do not match',  'ពាក្យសម្ងាត់មិនត្រូវគ្នា');
  String get requiredField        => _t('This field is required',  'ចាំបាច់ត្រូវវាយបញ្ចូល');
  String get invalidEmail         => _t('Invalid email address',   'អ៊ីមែលមិនត្រឹមត្រូវ');
  String get noData               => _t('No data available',       'គ្មានទិន្នន័យ');

  // ── Onboarding ────────────────────────────────────────────────────────────
  String get welcomeTitle1     => _t('Discover Products\nYou Love',          'ស្វែងរកផលិតផល\nដែលអ្នកចូលចិត្ត');
  String get welcomeDesc1      => _t('Browse curated devices and accessories.\nFind exactly what you need in seconds.', 'រកមើលឧបករណ៍ និងគ្រឿងបន្ថែម។\nស្វែងរកអ្វីដែលអ្នកត្រូវការ។');
  String get welcomeTitle2     => _t('Fast & Reliable\nRepair Service',       'សេវាជួសជុល\nរហ័ស និងអាចទុកចិត្ត');
  String get welcomeDesc2      => _t('Book a repair in minutes.\nTrack your device status in real-time.', 'ចុះឈ្មោះជួសជុលក្នុងរយៈពេលប៉ុន្មាននាទី។\nតាមដានស្ថានភាពក្នុងពេលជាក់ស្ដែង។');
  String get welcomeTitle3     => _t('Secure Payment\n& Easy Checkout',       'ការទូទាត់សុវត្ថិភាព\nទូទាត់ងាយស្រួល');
  String get welcomeDesc3      => _t('Multiple payment options.\nSafe, encrypted, and lightning fast.', 'ជម្រើសទូទាត់ច្រើន។\nសុវត្ថិភាព ការអ៊ិនគ្រីប និងរហ័ស។');
  String get chooseYourLanguage=> _t('Choose Your Language',                  'ជ្រើសរើសភាសារបស់អ្នក');
  String get languageDesc      => _t('Select your preferred language\nto get started.', 'ជ្រើសរើសភាសាដែលអ្នកចូលចិត្ត\nដើម្បីចាប់ផ្ដើម។');

  // ── KHQR / Bakong Payment ─────────────────────────────────────────────────
  String get khqrPayment          => _t('KHQR PAYMENT',                          'ការទូទាត់ KHQR');
  String get khqrScanInstruction  => _t('Scan the KHQR with Bakong or\nany supported banking app', 'ស្កែន KHQR ជាមួយ Bakong ឬ\nកម្មវិធីធនាគារដែលគាំទ្រ');
  String get khqrMerchant         => _t('Merchant',                               'ឈ្មោះអ្នកទទួល');
  String get khqrAmount           => _t('Amount',                                 'ចំនួនទឹកប្រាក់');
  String get khqrReference        => _t('Reference',                              'លេខយោង');
  String get khqrNetwork          => _t('Network',                                'បណ្តាញ');
  String get khqrExpiresIn        => _t('Expires In',                             'អស់សុពលភាព');
  String get khqrCheckingAuto     => _t('Checking payment automatically...','កំពុងត្រួតពិនិត្យការទូទាត់ដោយស្វ័យប្រវត្ដ...');
  String get khqrPendingPaused    => _t('Payment pending. Automatic check paused.', 'ការទូទាត់ចាំ។ ការត្រួតពិនិត្យស្វ័យប្រវត្ដបានផ្អាក។');
  String get khqrNoPaymentYet     => _t('No payment detected yet.',              'មិនទាន់រកឃើញការទូទាត់ទេ។');
  String get khqrCheckFailed      => _t('Check failed. Please check network connection.', 'ការត្រួតពិនិត្យបរាជ័យ។ សូមពិនិត្យការតភ្ជាប់បណ្ដាញ។');
  String get khqrPaymentSuccessful=> _t('Payment Successful',                    'ការទូទាត់បានជោគជ័យ');
  String get khqrPaymentProcessed => _t('Your payment was processed successfully.', 'ការទូទាត់របស់អ្នកបានដំណើរការដោយជោគជ័យ។');
  String get khqrPaymentFailed    => _t('Payment Failed',                        'ការទូទាត់បរាជ័យ');
  String get khqrPaymentExpired   => _t('Payment Expired',                       'ការទូទាត់អស់សុពលភាព');
  String get khqrBakongError      => _t('Bakong Check Error',                    'កំហុសការត្រួតពិនិត្យ Bakong');
  String get khqrQrExpired        => _t('QR expired. Please generate a new one.', 'QR អស់សុពលភាព។ សូមបង្កើតថ្មីម្ដងទៀត។');
  String get khqrSandboxUnauth    => _t('Sandbox check is unauthorized. Check credentials.', 'ការត្រួតពិនិត្យ Sandbox មិនត្រូវបានអនុញ្ញាត។');
  String get khqrSandboxUnavail   => _t('Bakong sandbox is currently unavailable.', 'Bakong Sandbox មិនអាចប្រើបានពេលនេះ។');
  String get khqrFailedDefault    => _t('Payment failed or cancelled. Please try again.', 'ការទូទាត់បរាជ័យ ឬត្រូវបានបោះបង់។ សូមព្យាយាមម្ដងទៀត។');
  String get khqrQrScanned        => _t('QR Code Scanned',                       'QR កូដបានស្កែន');
  String get khqrCompleteInApp    => _t('Please complete the transaction in your bank app.', 'សូមបញ្ចប់ប្រតិបត្តិការក្នុងកម្មវិធីធនាគាររបស់អ្នក។');
  String get khqrOrderId          => _t('Order ID',                              'លេខសម្គាល់ការបញ្ជាទិញ');
  String get khqrPaymentMethod    => _t('Payment Method',                        'វិធីសាស្ត្រទូទាត់');
  String get khqrReferenceCode    => _t('Reference Code',                        'លេខកូដយោង');
  String get khqrAmountDue        => _t('Amount Due',                            'ចំនួនទឹកប្រាក់ត្រូវបង់');
  String get khqrPdfComingSoon    => _t('PDF Receipt Coming Soon',               'វិក្កយបត្រ PDF មកដល់ឆាប់ៗ');
  String get khqrViewPickupTicket => _t('View Pickup Ticket',                    'មើលសំបុត្រទទួលទំនិញ');
  String get khqrOpeningTicket    => _t('Opening Pickup Ticket...',              'កំពុងបើកសំបុត្រទទួលទំនិញ...');
  String get khqrTicketNotReady   => _t('Ticket is generating. Please try again in a moment.', 'សំបុត្រកំពុងបង្កើត។ សូមព្យាយាមម្ដងទៀតក្នុងពេលបន្ដិច។');
  String get khqrCheckPayment     => _t('Check Payment Status',                  'ត្រួតពិនិត្យស្ថានភាពការទូទាត់');
  String get khqrChecking         => _t('Checking Payment...',                   'កំពុងត្រួតពិនិត្យការទូទាត់...');
}

// ── Delegate ──────────────────────────────────────────────────────────────────

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'km'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
