/// Form Validation Utilities
/// 
/// Provides comprehensive, reusable validation functions following
/// industry standards and best practices.
/// 
/// Features:
/// - Email validation (RFC 5322 compliant)
/// - Password validation (configurable strength)
/// - Name validation (international support)
/// - Phone validation (international formats)
/// - Custom validators
class Validators {
  // ============================================================================
  // EMAIL VALIDATION
  // ============================================================================
  
  /// Validates email address
  /// 
  /// Rules:
  /// - Must not be empty
  /// - Must match RFC 5322 email format
  /// - Must have valid domain
  /// - Must not contain spaces
  /// 
  /// Examples:
  /// - Valid: user@example.com, john.doe@company.co.uk
  /// - Invalid: user@, @example.com, user @example.com
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Trim whitespace
    value = value.trim();
    
    // Check for spaces
    if (value.contains(' ')) {
      return 'Email cannot contain spaces';
    }
    
    // RFC 5322 compliant email regex
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    // Check for common typos
    final commonTypos = {
      'gmial.com': 'gmail.com',
      'gmai.com': 'gmail.com',
      'yahooo.com': 'yahoo.com',
      'hotmial.com': 'hotmail.com',
      'outlok.com': 'outlook.com',
    };
    
    final domain = value.split('@').last.toLowerCase();
    if (commonTypos.containsKey(domain)) {
      return 'Did you mean ${value.split('@').first}@${commonTypos[domain]}?';
    }
    
    return null;
  }
  
  // ============================================================================
  // PASSWORD VALIDATION
  // ============================================================================
  
  /// Validates password with configurable strength requirements
  /// 
  /// Default Rules:
  /// - Minimum 8 characters (industry standard)
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  /// - At least one special character
  /// 
  /// Can be configured for different strength levels
  static String? validatePassword(
    String? value, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumber = true,
    bool requireSpecialChar = true,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    // Check minimum length
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    
    // Check maximum length (prevent DoS attacks)
    if (value.length > 128) {
      return 'Password must be less than 128 characters';
    }
    
    // Check for uppercase letter
    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for lowercase letter
    if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for number
    if (requireNumber && !value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    // Check for special character
    if (requireSpecialChar && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    // Check for common weak passwords
    final weakPasswords = [
      'password', 'password123', '12345678', 'qwerty', 'abc123',
      'letmein', 'welcome', 'monkey', '1234567890', 'password1',
    ];
    
    if (weakPasswords.contains(value.toLowerCase())) {
      return 'This password is too common. Please choose a stronger one';
    }
    
    return null;
  }
  
  /// Validates password for signup (stricter rules)
  static String? validateSignupPassword(String? value) {
    return validatePassword(
      value,
      minLength: 8,
      requireUppercase: true,
      requireLowercase: true,
      requireNumber: true,
      requireSpecialChar: false, // Optional for better UX
    );
  }
  
  /// Validates password for login (lenient rules)
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  /// Validates password confirmation
  static String? validatePasswordConfirmation(
    String? value,
    String? password,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  // ============================================================================
  // NAME VALIDATION
  // ============================================================================
  
  /// Validates full name
  /// 
  /// Rules:
  /// - Must not be empty
  /// - Minimum 2 characters
  /// - Maximum 50 characters
  /// - Can contain letters, spaces, hyphens, apostrophes
  /// - Supports international characters (Unicode)
  /// 
  /// Examples:
  /// - Valid: John Doe, María García, O'Brien, Jean-Pierre
  /// - Invalid: J, 123, @#$
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    // Trim whitespace
    value = value.trim();
    
    // Check minimum length
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    // Check maximum length
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    // Allow letters (including Unicode), spaces, hyphens, apostrophes
    final nameRegex = RegExp(r"^[\p{L}\s\-']+$", unicode: true);
    
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    // Check for excessive spaces
    if (value.contains(RegExp(r'\s{2,}'))) {
      return 'Name cannot contain multiple consecutive spaces';
    }
    
    // Check for leading/trailing special characters
    if (value.startsWith('-') || value.startsWith("'") || 
        value.endsWith('-') || value.endsWith("'")) {
      return 'Name cannot start or end with special characters';
    }
    
    return null;
  }
  
  /// Validates first name
  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    
    value = value.trim();
    
    if (value.length < 2) {
      return 'First name must be at least 2 characters';
    }
    
    if (value.length > 30) {
      return 'First name must be less than 30 characters';
    }
    
    final nameRegex = RegExp(r"^[\p{L}\-']+$", unicode: true);
    
    if (!nameRegex.hasMatch(value)) {
      return 'First name can only contain letters, hyphens, and apostrophes';
    }
    
    return null;
  }
  
  /// Validates last name
  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    
    value = value.trim();
    
    if (value.length < 2) {
      return 'Last name must be at least 2 characters';
    }
    
    if (value.length > 30) {
      return 'Last name must be less than 30 characters';
    }
    
    final nameRegex = RegExp(r"^[\p{L}\-']+$", unicode: true);
    
    if (!nameRegex.hasMatch(value)) {
      return 'Last name can only contain letters, hyphens, and apostrophes';
    }
    
    return null;
  }
  
  // ============================================================================
  // PHONE VALIDATION
  // ============================================================================
  
  /// Validates phone number (international format)
  /// 
  /// Rules:
  /// - Must not be empty
  /// - Can start with + for country code
  /// - Must contain 10-15 digits
  /// - Can contain spaces, hyphens, parentheses for formatting
  /// 
  /// Examples:
  /// - Valid: +1 (555) 123-4567, 5551234567, +44 20 7123 4567
  /// - Invalid: 123, abc, 12345
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove formatting characters
    final digitsOnly = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    
    // Check if contains only digits
    if (!RegExp(r'^\d+$').hasMatch(digitsOnly)) {
      return 'Phone number can only contain digits';
    }
    
    // Check length (10-15 digits for international numbers)
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    
    if (digitsOnly.length > 15) {
      return 'Phone number must be less than 15 digits';
    }
    
    return null;
  }
  
  // ============================================================================
  // GENERAL VALIDATORS
  // ============================================================================
  
  /// Validates required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  /// Validates minimum length
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    return null;
  }
  
  /// Validates maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    
    return null;
  }
  
  /// Validates numeric input
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return '$fieldName must contain only numbers';
    }
    
    return null;
  }
  
  /// Validates alphanumeric input
  static String? validateAlphanumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return '$fieldName must contain only letters and numbers';
    }
    
    return null;
  }
  
  /// Validates URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  // ============================================================================
  // PET-SPECIFIC VALIDATORS
  // ============================================================================
  
  /// Validates pet name
  static String? validatePetName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pet name is required';
    }
    
    value = value.trim();
    
    if (value.length < 2) {
      return 'Pet name must be at least 2 characters';
    }
    
    if (value.length > 30) {
      return 'Pet name must be less than 30 characters';
    }
    
    // Allow letters, spaces, hyphens, apostrophes
    final nameRegex = RegExp(r"^[\p{L}\s\-']+$", unicode: true);
    
    if (!nameRegex.hasMatch(value)) {
      return 'Pet name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }
  
  /// Validates pet breed
  static String? validateBreed(String? value) {
    if (value == null || value.isEmpty) {
      return 'Breed is required';
    }
    
    value = value.trim();
    
    if (value.length < 2) {
      return 'Breed must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return 'Breed must be less than 50 characters';
    }
    
    return null;
  }
  
  /// Validates pet age
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    
    final age = int.tryParse(value);
    
    if (age == null) {
      return 'Age must be a number';
    }
    
    if (age < 0) {
      return 'Age cannot be negative';
    }
    
    if (age > 30) {
      return 'Please enter a valid age (0-30 years)';
    }
    
    return null;
  }
  
  /// Validates pet weight
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }
    
    final weight = double.tryParse(value);
    
    if (weight == null) {
      return 'Weight must be a number';
    }
    
    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }
    
    if (weight > 200) {
      return 'Please enter a valid weight (0-200 kg)';
    }
    
    return null;
  }
  
  /// Validates pet description
  static String? validateDescription(String? value, {bool required = false}) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'Description is required';
    }
    
    if (value != null && value.trim().isNotEmpty) {
      if (value.length < 10) {
        return 'Description must be at least 10 characters';
      }
      
      if (value.length > 500) {
        return 'Description must be less than 500 characters';
      }
    }
    
    return null;
  }
  
  // ============================================================================
  // BOOKING-SPECIFIC VALIDATORS
  // ============================================================================
  
  /// Validates service price
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    
    final price = double.tryParse(value);
    
    if (price == null) {
      return 'Price must be a number';
    }
    
    if (price < 0) {
      return 'Price cannot be negative';
    }
    
    if (price > 10000) {
      return 'Please enter a valid price';
    }
    
    return null;
  }
  
  /// Validates date (not in the past)
  static String? validateFutureDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(value.year, value.month, value.day);
    
    if (selectedDate.isBefore(today)) {
      return 'Date cannot be in the past';
    }
    
    // Check if date is too far in the future (1 year)
    final oneYearFromNow = today.add(const Duration(days: 365));
    if (selectedDate.isAfter(oneYearFromNow)) {
      return 'Date cannot be more than 1 year in the future';
    }
    
    return null;
  }
  
  /// Validates time slot
  static String? validateTimeSlot(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time slot is required';
    }
    
    return null;
  }
  
  /// Validates address
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    
    value = value.trim();
    
    if (value.length < 10) {
      return 'Address must be at least 10 characters';
    }
    
    if (value.length > 200) {
      return 'Address must be less than 200 characters';
    }
    
    return null;
  }
  
  /// Validates special instructions
  static String? validateSpecialInstructions(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (value.length > 500) {
        return 'Special instructions must be less than 500 characters';
      }
    }
    
    return null;
  }
  
  // ============================================================================
  // CAREGIVER-SPECIFIC VALIDATORS
  // ============================================================================
  
  /// Validates experience years
  static String? validateExperience(String? value) {
    if (value == null || value.isEmpty) {
      return 'Experience is required';
    }
    
    final years = int.tryParse(value);
    
    if (years == null) {
      return 'Experience must be a number';
    }
    
    if (years < 0) {
      return 'Experience cannot be negative';
    }
    
    if (years > 50) {
      return 'Please enter valid years of experience';
    }
    
    return null;
  }
  
  /// Validates hourly rate
  static String? validateHourlyRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Hourly rate is required';
    }
    
    final rate = double.tryParse(value);
    
    if (rate == null) {
      return 'Hourly rate must be a number';
    }
    
    if (rate < 0) {
      return 'Hourly rate cannot be negative';
    }
    
    if (rate > 1000) {
      return 'Please enter a valid hourly rate';
    }
    
    return null;
  }
  
  /// Validates bio/about section
  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bio is required';
    }
    
    value = value.trim();
    
    if (value.length < 50) {
      return 'Bio must be at least 50 characters';
    }
    
    if (value.length > 1000) {
      return 'Bio must be less than 1000 characters';
    }
    
    return null;
  }
  
  // ============================================================================
  // RATING & REVIEW VALIDATORS
  // ============================================================================
  
  /// Validates rating value
  static String? validateRating(double? value) {
    if (value == null) {
      return 'Rating is required';
    }
    
    if (value < 1 || value > 5) {
      return 'Rating must be between 1 and 5';
    }
    
    return null;
  }
  
  /// Validates review text
  static String? validateReview(String? value) {
    if (value == null || value.isEmpty) {
      return 'Review is required';
    }
    
    value = value.trim();
    
    if (value.length < 10) {
      return 'Review must be at least 10 characters';
    }
    
    if (value.length > 500) {
      return 'Review must be less than 500 characters';
    }
    
    return null;
  }
  
  // ============================================================================
  // CUSTOM VALIDATORS
  // ============================================================================
  
  /// Combines multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
  
  /// Creates a custom validator with a condition
  static String? Function(String?) custom(
    bool Function(String?) condition,
    String errorMessage,
  ) {
    return (value) {
      if (!condition(value)) {
        return errorMessage;
      }
      return null;
    };
  }
}
