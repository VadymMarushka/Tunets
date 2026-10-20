/// All user-facing strings. The interface language is English (LR2);
/// keeping strings here makes adding other languages later straightforward.
abstract final class AppStrings {
  static const appName = 'Tunets';
  static const tagline = 'Every catch, remembered.';

  // Navigation
  static const navHome = 'Home';
  static const navTrips = 'Trips';
  static const navProfile = 'Profile';
  static const back = 'Back';
  static const showPassword = 'Show password';
  static const hidePassword = 'Hide password';

  // Auth: sign in (S-1)
  static const signIn = 'Sign in';
  static const email = 'Email';
  static const password = 'Password';
  static const forgotPassword = 'Forgot password?';
  static const newHere = 'New here?';
  static const register = 'Register';

  // Auth: register (S-2)
  static const createAccount = 'Create account';
  static const createAccountSubtitle = 'Start your fishing diary.';
  static const name = 'Name';
  static const confirmPassword = 'Confirm password';
  static const passwordHint = 'At least 8 characters';
  static const alreadyHaveAccount = 'Already have an account?';

  // Auth: reset password (S-3)
  static const resetPassword = 'Reset password';
  static const resetPasswordDescription =
      'Enter the email you used to register. '
      'We will send you a link to create a new password.';
  static const sendResetLink = 'Send reset link';
  static const checkInbox = 'Check your inbox.';
  static String resetLinkSent(String email) =>
      'We sent a reset link to $email.';
  static const rememberedIt = 'Remembered it?';
  static const backToSignIn = 'Back to sign in';

  // Home (S-4)
  static const goodMorning = 'Good morning';
  static const goodAfternoon = 'Good afternoon';
  static const goodEvening = 'Good evening';
  static String greeting(String salutation, String name) =>
      '$salutation, $name';
  static const synced = 'Synced';
  static const offline = 'Offline';
  static const recentTrips = 'Recent trips';
  static const seeAll = 'See all';
  static const seeAllTrips = 'See all trips';
  static const addTrip = 'Add trip';
  static const summary = 'Summary';
  static const tripsThisMonth = 'Trips this month';
  static const totalCatch = 'Total catch';
  static const bestCatch = 'Best catch';

  // Trips list (S-5)
  static const searchByWaterBody = 'Search by water body';
  static const filterAll = 'All';
  static const filterThisMonth = 'This month';
  static const filterThisYear = 'This year';
  static String tripsCount(int count) => count == 1 ? '1 trip' : '$count trips';
  static const noTripsYet = 'No trips yet';
  static const noTripsYetMessage = 'Trips you log will appear here.';
  static const addFirstTrip = 'Add your first trip';
  static const noMatchingTrips = 'No matching trips';
  static const noMatchingTripsMessage =
      'Try another water body or change the filter.';
  static const selectTripHint = 'Select a trip to see its details.';

  // Trip details (S-7)
  static const tripDetails = 'Trip details';
  static const open = 'Open';
  static const edit = 'Edit';
  static const delete = 'Delete';
  static const weather = 'Weather';
  static const temperature = 'Temperature';
  static const pressure = 'Pressure';
  static const wind = 'Wind';
  static const tackle = 'Tackle';
  static const catchTitle = 'Catch';
  static String catchWithCount(int fish) =>
      fish == 1 ? 'Catch · 1 fish' : 'Catch · $fish fish';
  static String fishCount(int fish) => fish == 1 ? '1 fish' : '$fish fish';
  static const total = 'Total';
  static const noCatch = 'No catch';
  static const noCatchMessage = 'No catch on this trip.';
  static const notes = 'Notes';
  static const deleteTripTitle = 'Delete this trip?';
  static const deleteTripMessage = 'This action cannot be undone.';
  static const tripDeleted = 'Trip deleted';

  // Trip form (S-6)
  static const editTrip = 'Edit trip';
  static const trip = 'Trip';
  static const date = 'Date';
  static const time = 'Time';
  static const waterBody = 'Water body';
  static const waterBodyRequired = 'Water body *';
  static const selectWaterBody = 'Select water body';
  static const waterBodyIsRequired = 'Water body is required';
  static const temperatureC = 'Temperature, °C';
  static const pressureHpa = 'Pressure, hPa';
  static const windSpeed = 'Wind speed, m/s';
  static const windDirection = 'Wind direction';
  static const select = 'Select';
  static const addTackle = 'Add tackle';
  static const tackleName = 'Tackle name';
  static const add = 'Add';
  static const addCatch = 'Add catch';
  static String catchNumber(int n) => 'Catch $n';
  static const species = 'Species';
  static const selectSpecies = 'Select species';
  static const weightKg = 'Weight, kg';
  static const count = 'Count';
  static const notesHint = 'Bait, spot, bites, anything worth remembering';
  static const save = 'Save';
  static const cancel = 'Cancel';
  static const remove = 'Remove';
  static const tripSaved = 'Trip saved';
  static const fillRequiredField = 'Fill in the required field marked below.';

  // Photos (FR-5, UI only in this lab)
  static const addPhoto = 'Add photo';
  static const changePhoto = 'Change photo';
  static const takePhoto = 'Take photo with camera';
  static const chooseFromGallery = 'Choose from gallery';
  static const removePhoto = 'Remove photo';
  static const dragPhotoHere = 'Drag a photo here';
  static const browseFilesPrefix = 'or ';
  static const browseFiles = 'browse files';
  static const photoRequirements = 'JPG or PNG, up to 10 MB';
  static const dropImageOrBrowse = 'Drop an image or browse files';
  static const photoNotAvailable =
      'Photo upload will be connected in the next lab.';

  // Profile (S-8)
  static const personalInfo = 'Personal info';
  static const emailCantBeChanged = "Email can't be changed";
  static const phoneOptional = 'Phone (optional)';
  static const phoneHint = '+380 XX XXX XX XX';
  static const optional = 'Optional';
  static const saveChanges = 'Save changes';
  static const profileSaved = 'Profile saved';
  static const changePassword = 'Change password';
  static const currentPassword = 'Current password';
  static const newPassword = 'New password';
  static const confirmNewPassword = 'Confirm new password';
  static const updatePassword = 'Update password';
  static const passwordUpdated = 'Password updated';
  static const signOut = 'Sign out';
}
