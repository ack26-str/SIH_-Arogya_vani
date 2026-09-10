import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final selectedLanguageCodeProvider = StateProvider<String>((ref) => 'en');

/// Localization service providing translations for:
/// English (en), Hindi (hi), Malayalam (ml), Tamil (ta), Telugu (te), Kannada (kn).
class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations of(BuildContext context, [WidgetRef? ref]) {
    if (ref != null) {
      final code = ref.watch(selectedLanguageCodeProvider);
      return AppLocalizations(code);
    }
    return AppLocalizations('en');
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'AarogyaVani',
      'tagline': 'Your health. Your voice. Better care.',
      'getStarted': 'Get Started',
      'alreadyAccount': 'Already have an account?',
      'welcomeHeadline': "Let's understand your health better.",
      'welcomeSubtitle':
          'Share your symptoms, medical history, and health records through a simple conversation.',
      'selectLanguage': 'Select Preferred Language',
      'chooseLanguageDesc':
          'Choose the language you feel most comfortable speaking and reading in.',
      'continueBtn': 'Continue',
      'profileSetup': 'Patient Profile',
      'profileSetupDesc': 'Help us personalize your clinical intake record.',
      'fullName': 'Full Name',
      'age': 'Age',
      'gender': 'Gender',
      'phone': 'Phone Number',
      'email': 'Email (Optional)',
      'male': 'Male',
      'female': 'Female',
      'other': 'Other',
      'skip': 'Skip for now',
      'home': 'Home',
      'consultation': 'Consultation',
      'records': 'Records',
      'profile': 'Profile',
      'goodMorning': 'Good day',
      'howCanWeHelp': 'How can we help you today?',
      'startNewConsultation': 'Start a new consultation',
      'tellUsWhatExperiencing': "Tell us what symptoms you're experiencing.",
      'medicalRecordsTitle': 'Medical Records',
      'uploadedRecordsCount': 'records uploaded and indexed',
      'viewRecords': 'View Records',
      'uploadRecord': 'Upload Record',
      'previousConsultations': 'Previous Consultations',
      'viewSummary': 'View Summary',
      'quickActions': 'Quick Actions',
      'clinicalAssistant': 'Clinical Assistant',
      'assistantStatus': 'Collecting your health information',
      'typeYourMessage': 'Describe symptoms (e.g. fever, headache)...',
      'voiceRecording': 'Listening... Speak naturally',
      'send': 'Send',
      'uploadTitle': 'Upload your medical record',
      'uploadSubtitle':
          'Lab reports, prescriptions, discharge summaries (PDF, JPG, PNG)',
      'chooseFile': 'Choose File',
      'sampleFiles': 'Or choose a sample clinical record',
      'analyzingDocument': 'Analyzing your medical record...',
      'stepUploaded': 'Document uploaded successfully',
      'stepExtracted': 'Text extracted via OCR engine',
      'stepIdentifying': 'Identifying medical information',
      'stepPreparing': 'Preparing structured clinical summary',
      'extractedInfoTitle': 'Extracted Medical Information',
      'reviewNotice':
          'Please review this information before continuing. Extracted medical data should be verified.',
      'patientInfo': 'Patient Information',
      'diagnoses': 'Diagnoses / Findings',
      'medications': 'Medications',
      'allergies': 'Allergies',
      'labResults': 'Lab Results',
      'previousTreatments': 'Previous Treatments',
      'medicalHistory': 'Medical History',
      'clinicalSummaryTitle': 'Clinical Intake Summary',
      'chiefComplaint': 'Chief Complaint',
      'symptoms': 'Reported Symptoms',
      'symptomDetails': 'Symptom Breakdown',
      'currentMedications': 'Current Medications',
      'attachedRecords': 'Attached Records',
      'additionalNotes': 'Additional Notes',
      'editInformation': 'Edit Information',
      'confirmSummary': 'Confirm Summary',
      'shareWithClinician': 'Share with Clinician',
      'summaryConfirmedNotice': 'Clinical intake summary confirmed and saved.',
      'disclaimer':
          'This assistant helps collect and organize health information. It does not provide a medical diagnosis. Please consult a qualified healthcare professional for medical advice.',
      'settings': 'Settings',
      'privacyData': 'Privacy & Data Management',
      'notifications': 'Notifications',
      'aboutApp': 'About AarogyaVani',
      'logout': 'Reset Session / New Patient',
      'yetToIntegrate': 'Yet to integrate',
      'consentTitle': 'Patient Consent & Privacy',
      'sessionTitle': 'Kiosk Session & Department',
      'allopathicOpd': 'Allopathic OPD',
      'ayushOpd': 'AYUSH OPD',
      'emergencyTriage': 'Emergency Red-Flag Screening',
      'abhaId': 'ABHA Health ID',
      'agreeAndProceed': 'Agree & Proceed',
      'launchSession': 'Launch Kiosk Session',
    },
    'hi': {
      'appName': 'आरोग्यवाणी',
      'tagline': 'आपका स्वास्थ्य। आपकी आवाज़। बेहतर देखभाल।',
      'getStarted': 'शुरू करें',
      'alreadyAccount': 'क्या आपके पास पहले से खाता है?',
      'welcomeHeadline': 'आइए अपने स्वास्थ्य को बेहतर समझें।',
      'welcomeSubtitle':
          'सरल बातचीत के माध्यम से अपने लक्षण, चिकित्सा इतिहास और स्वास्थ्य रिकॉर्ड साझा करें।',
      'selectLanguage': 'पसंदीदा भाषा चुनें',
      'chooseLanguageDesc': 'वह भाषा चुनें जिसमें आप सबसे सहज महसूस करते हैं।',
      'continueBtn': 'आगे बढ़ें',
      'profileSetup': 'रोगी प्रोफ़ाइल',
      'profileSetupDesc': 'क्लिनिकल इनटेक रिकॉर्ड तैयार करने में मदद करें।',
      'fullName': 'पूरा नाम',
      'age': 'उम्र',
      'gender': 'लिंग',
      'phone': 'फ़ोन नंबर',
      'email': 'ईमेल (वैकल्पिक)',
      'male': 'पुरुष',
      'female': 'महिला',
      'other': 'अन्य',
      'skip': 'अभी छोड़ें',
      'home': 'होम',
      'consultation': 'परामर्श',
      'records': 'रिकॉर्ड',
      'profile': 'प्रोफ़ाइल',
      'goodMorning': 'नमस्ते',
      'howCanWeHelp': 'आज हम आपकी क्या मदद कर सकते हैं?',
      'startNewConsultation': 'नया परामर्श शुरू करें',
      'tellUsWhatExperiencing': 'हमें बताएं कि आप क्या लक्षण महसूस कर रहे हैं।',
      'medicalRecordsTitle': 'चिकित्सा रिकॉर्ड',
      'uploadedRecordsCount': 'रिकॉर्ड अपलोड और विश्लेषित किए गए',
      'viewRecords': 'रिकॉर्ड देखें',
      'uploadRecord': 'रिकॉर्ड अपलोड करें',
      'previousConsultations': 'पिछले परामर्श',
      'viewSummary': 'सारांश देखें',
      'quickActions': 'त्वरित क्रियाएं',
      'clinicalAssistant': 'क्लिनिकल सहायक',
      'assistantStatus': 'आपकी स्वास्थ्य जानकारी एकत्रित कर रहे हैं',
      'typeYourMessage': 'लक्षण लिखें (जैसे बुखार, सिरदर्द)...',
      'voiceRecording': 'सुन रहे हैं... स्वाभाविक रूप से बोलें',
      'send': 'भेजें',
      'uploadTitle': 'अपना मेडिकल रिकॉर्ड अपलोड करें',
      'uploadSubtitle': 'लैब रिपोर्ट, पर्चे, डिस्चार्ज सारांश (PDF, JPG, PNG)',
      'chooseFile': 'फ़ाइल चुनें',
      'sampleFiles': 'या एक नमूना मेडिकल रिकॉर्ड चुनें',
      'analyzingDocument': 'आपके मेडिकल रिकॉर्ड का विश्लेषण कर रहे हैं...',
      'stepUploaded': 'दस्तावेज़ सफलतापूर्वक अपलोड हुआ',
      'stepExtracted': 'OCR इंजन द्वारा पाठ निकाला गया',
      'stepIdentifying': 'चिकित्सा जानकारी की पहचान की जा रही है',
      'stepPreparing': 'संरचित क्लिनिकल सारांश तैयार हो रहा है',
      'extractedInfoTitle': 'निकाली गई चिकित्सा जानकारी',
      'reviewNotice':
          'कृपया जारी रखने से पहले इस जानकारी की समीक्षा करें। जानकारी सत्यापित की जानी चाहिए।',
      'patientInfo': 'रोगी की जानकारी',
      'diagnoses': 'निदान / निष्कर्ष',
      'medications': 'दवाएं',
      'allergies': 'एलर्जी',
      'labResults': 'लैब परिणाम',
      'previousTreatments': 'पिछले उपचार',
      'medicalHistory': 'चिकित्सा इतिहास',
      'clinicalSummaryTitle': 'क्लिनिकल इनटेक सारांश',
      'chiefComplaint': 'मुख्य शिकायत',
      'symptoms': 'सूचित लक्षण',
      'symptomDetails': 'लक्षणों का विवरण',
      'currentMedications': 'वर्तमान दवाएं',
      'attachedRecords': 'संलग्न रिकॉर्ड',
      'additionalNotes': 'अतिरिक्त नोट्स',
      'editInformation': 'जानकारी संपादित करें',
      'confirmSummary': 'सारांश की पुष्टि करें',
      'shareWithClinician': 'डॉक्टर/चिकित्सक के साथ साझा करें',
      'summaryConfirmedNotice': 'क्लिनिकल इनटेक सारांश सहेजा गया।',
      'disclaimer':
          'यह सहायक केवल स्वास्थ्य जानकारी एकत्रित करता है। यह कोई चिकित्सीय निदान नहीं देता है।',
      'settings': 'सेटिंग्स',
      'privacyData': 'गोपनीयता और डेटा प्रबंधन',
      'notifications': 'सूचनाएं',
      'aboutApp': 'आरोग्यवाणी के बारे में',
      'logout': 'सत्र रीसेट करें',
      'yetToIntegrate': 'एकीकरण बाकी है',
      'consentTitle': 'रोगी सहमति और गोपनीयता',
      'sessionTitle': 'कियोस्क सत्र और विभाग',
      'allopathicOpd': 'एलोपैथिक ओपीडी',
      'ayushOpd': 'आयुष ओपीडी',
      'emergencyTriage': 'आपातकालीन रेड-फ्लैग स्क्रीनिंग',
      'abhaId': 'आभा (ABHA) स्वास्थ्य पहचान',
      'agreeAndProceed': 'सहमत और आगे बढ़ें',
      'launchSession': 'कियोस्क सत्र शुरू करें',
    },
    'ml': {
      'appName': 'ആരോഗ്യവാണി',
      'tagline': 'നിങ്ങളുടെ ആരോഗ്യം. നിങ്ങളുടെ ശബ്ദം. മികച്ച പരിചരണം.',
      'getStarted': 'ആരംഭിക്കുക',
      'alreadyAccount': 'ഇതിനകം അക്കൗണ്ട് ഉണ്ടോ?',
      'welcomeHeadline': 'നിങ്ങളുടെ ആരോഗ്യം കൂടുതൽ നന്നായി മനസ്സിലാക്കാം.',
      'welcomeSubtitle':
          'ലളിതമായ സംഭാഷണത്തിലൂടെ രോഗലക്ഷണങ്ങളും മെഡിക്കൽ രേഖകളും പങ്കിടുക.',
      'selectLanguage': 'ഭാഷ തിരഞ്ഞെടുക്കുക',
      'chooseLanguageDesc': 'നിങ്ങൾക്ക് ഏറ്റവും എളുപ്പമുള്ള ഭാഷ തിരഞ്ഞെടുക്കുക.',
      'continueBtn': 'തുടരുക',
      'profileSetup': 'രോഗിയുടെ വിവരങ്ങൾ',
      'profileSetupDesc': 'നിങ്ങളുടെ ക്ലിനിക്കൽ ഇൻടേക്ക് തയ്യാറാക്കാൻ സഹായിക്കുക.',
      'fullName': 'പൂർണ്ണ നാമം',
      'age': 'പ്രായം',
      'gender': 'ലിംഗഭേദം',
      'phone': 'ഫോൺ നമ്പർ',
      'email': 'ഇമെയിൽ (ഓപ്ഷണൽ)',
      'male': 'പുരുഷൻ',
      'female': 'സ്ത്രീ',
      'other': 'മറ്റുള്ളവ',
      'skip': 'ഇപ്പോൾ ഒഴിവാക്കുക',
      'home': 'ഹോം',
      'consultation': 'കൺസൾട്ടേഷൻ',
      'records': 'രേഖകൾ',
      'profile': 'പ്രൊഫൈൽ',
      'goodMorning': 'നമസ്കാരം',
      'howCanWeHelp': 'ഞങ്ങൾക്ക് ഇന്ന് നിങ്ങളെ എങ്ങനെ സഹായിക്കാനാകും?',
      'startNewConsultation': 'പുതിയ കൺസൾട്ടേഷൻ ആരംഭിക്കുക',
      'tellUsWhatExperiencing': 'നിങ്ങൾക്ക് അനുഭവപ്പെടുന്ന ലക്ഷണങ്ങൾ പറയുക.',
      'medicalRecordsTitle': 'മെഡിക്കൽ രേഖകൾ',
      'uploadedRecordsCount': 'രേഖകൾ പരിശോധിച്ചു',
      'viewRecords': 'രേഖകൾ കാണുക',
      'uploadRecord': 'രേഖ അപ്‌ലോഡ് ചെയ്യുക',
      'previousConsultations': 'മുൻകാല കൺസൾട്ടേഷനുകൾ',
      'viewSummary': 'സംഗ്രഹം കാണുക',
      'quickActions': 'വേഗത്തിലുള്ള പ്രവർത്തനങ്ങൾ',
      'clinicalAssistant': 'ക്ലിനിക്കൽ അസിസ്റ്റന്റ്',
      'assistantStatus': 'ആരോഗ്യ വിവരങ്ങൾ ശേഖരിക്കുന്നു',
      'typeYourMessage': 'ലക്ഷണങ്ങൾ എഴുതുക (ഉദാ: പനി, തലവേദന)...',
      'voiceRecording': 'ശ്രദ്ധിക്കുന്നു... സംസാരിക്കുക',
      'send': 'അയക്കുക',
      'uploadTitle': 'മെഡിക്കൽ രേഖ അപ്‌ലോഡ് ചെയ്യുക',
      'uploadSubtitle': 'ലാബ് റിപ്പോർട്ട്, കുറിപ്പടി (PDF, JPG, PNG)',
      'chooseFile': 'ഫയൽ തിരഞ്ഞെടുക്കുക',
      'sampleFiles': 'അല്ലെങ്കിൽ മാതൃകാ രേഖ തിരഞ്ഞെടുക്കുക',
      'analyzingDocument': 'രേഖകൾ പരിശോധിക്കുന്നു...',
      'stepUploaded': 'ഫയൽ അപ്‌ലോഡ് ചെയ്തു',
      'stepExtracted': 'വിവരങ്ങൾ വായിച്ചെടുത്തു',
      'stepIdentifying': 'മെഡിക്കൽ വിവരങ്ങൾ കണ്ടെത്തുന്നു',
      'stepPreparing': 'ക്ലിനിക്കൽ സംഗ്രഹം തയ്യാറാക്കുന്നു',
      'extractedInfoTitle': 'കണ്ടെത്തിയ മെഡിക്കൽ വിവരങ്ങൾ',
      'reviewNotice':
          'ദയവായി ഈ വിവരങ്ങൾ പരിശോധിക്കുക. ആവശ്യമെങ്കിൽ തിരുത്തലുകൾ വരുത്താം.',
      'patientInfo': 'രോഗിയുടെ വിവരങ്ങൾ',
      'diagnoses': 'കണ്ടെത്തലുകൾ',
      'medications': 'മരുന്നുകൾ',
      'allergies': 'അലർജികൾ',
      'labResults': 'ലാബ് പരിശോധനാ ഫലങ്ങൾ',
      'previousTreatments': 'മുൻകാല ചികിത്സകൾ',
      'medicalHistory': 'ചികിത്സാ ചരിത്രം',
      'clinicalSummaryTitle': 'ക്ലിനിക്കൽ ഇൻടേക്ക് സംഗ്രഹം',
      'chiefComplaint': 'പ്രധാന അസ്വസ്ഥത',
      'symptoms': 'രോഗലക്ഷണങ്ങൾ',
      'symptomDetails': 'ലക്ഷണങ്ങളുടെ വിശദാംശങ്ങൾ',
      'currentMedications': 'നിലവിലെ മരുന്നുകൾ',
      'attachedRecords': 'ചേർത്ത രേഖകൾ',
      'additionalNotes': 'കൂടുതൽ വിവരങ്ങൾ',
      'editInformation': 'വിവരങ്ങൾ തിരുത്തുക',
      'confirmSummary': 'സംഗ്രഹം സ്ഥിരീകരിക്കുക',
      'shareWithClinician': 'ഡോക്ടറുമായി പങ്കിടുക',
      'summaryConfirmedNotice': 'സംഗ്രഹം സ്ഥിരീകരിച്ചു.',
      'disclaimer':
          'ഈ ആപ്പ് വിവരങ്ങൾ ശേഖരിക്കാൻ മാത്രമുള്ളതാണ്. ഇത് രോഗനിർണയം നടത്തുന്നില്ല.',
      'settings': 'ക്രമീകരണങ്ങൾ',
      'privacyData': 'സ്വകാര്യതയും ഡാറ്റയും',
      'notifications': 'അറിയിപ്പുകൾ',
      'aboutApp': 'ആരോഗ്യവാണിയെക്കുറിച്ച്',
      'logout': 'സെഷൻ അവസാനിപ്പിക്കുക',
      'yetToIntegrate': 'ഉടൻ ലഭ്യമാകും',
      'consentTitle': 'രോഗി സമ്മതവും സ്വകാര്യതയും',
      'sessionTitle': 'കിയോസ്‌ക് സെഷനും വിഭാഗവും',
      'allopathicOpd': 'അലോപ്പതിക് ഒപി',
      'ayushOpd': 'ആയുഷ് ഒപി',
      'emergencyTriage': 'അടിയന്തര റെഡ്-ഫ്ലാഗ് സ്ക്രീനിംഗ്',
      'abhaId': 'ആഭ (ABHA) ഹെൽത്ത് ഐഡി',
      'agreeAndProceed': 'സമ്മതിച്ചു മുന്നോട്ട് പോകുക',
      'launchSession': 'സെഷൻ ആരംഭിക്കുക',
    },
    'ta': {
      'appName': 'ஆரோக்கியவாணி',
      'tagline': 'உங்கள் உடல்நலம். உங்கள் குரல். சிறந்த கவனிப்பு.',
      'getStarted': 'தொடங்குங்கள்',
      'alreadyAccount': 'ஏற்கனவே கணக்கு உள்ளதா?',
      'welcomeHeadline': 'உங்கள் உடல்நலத்தை நன்கு புரிந்துகொள்வோம்.',
      'welcomeSubtitle':
          'எளிய உரையாடலின் மூலம் உங்கள் அறிகுறிகளையும் மருத்துவ பதிவுகளையும் பகிருங்கள்.',
      'selectLanguage': 'மொழியைத் தேர்ந்தெடுக்கவும்',
      'chooseLanguageDesc': 'உங்களுக்கு வசதியான மொழியைத் தேர்வுசெய்யவும்.',
      'continueBtn': 'தொடரவும்',
      'profileSetup': 'நோயாளி சுயவிவரம்',
      'profileSetupDesc': 'உங்கள் மருத்துவ விவரங்களை உள்ளிடவும்.',
      'fullName': 'முழுப் பெயர்',
      'age': 'வயது',
      'gender': 'பாலினம்',
      'phone': 'தொலைபேசி எண்',
      'email': 'மின்னஞ்சல் (விருப்பத்தேர்வு)',
      'male': 'ஆண்',
      'female': 'பெண்',
      'other': 'மற்றவை',
      'skip': 'இப்போதைக்கு தவிர்',
      'home': 'முகப்பு',
      'consultation': 'ஆலோசனை',
      'records': 'பதிவுகள்',
      'profile': 'சுயவிவரம்',
      'goodMorning': 'வணக்கம்',
      'howCanWeHelp': 'இன்று உங்களுக்கு எவ்வாறு உதவலாம்?',
      'startNewConsultation': 'புதிய ஆலோசனையைத் தொடங்கு',
      'tellUsWhatExperiencing': 'உங்கள் அறிகுறிகளை எங்களிடம் கூறுங்கள்.',
      'medicalRecordsTitle': 'மருத்துவ பதிவுகள்',
      'uploadedRecordsCount': 'பதிவுகள் பகுப்பாய்வு செய்யப்பட்டன',
      'viewRecords': 'பதிவுகளைப் பார்',
      'uploadRecord': 'பதிவேற்று',
      'previousConsultations': 'முந்தைய ஆலோசனைகள்',
      'viewSummary': 'சுருக்கம் பார்க்கவும்',
      'quickActions': 'விரைவு செயல்கள்',
      'clinicalAssistant': 'மருத்துவ உதவியாளர்',
      'assistantStatus': 'தகவல் சேகரிக்கப்படுகிறது',
      'typeYourMessage': 'அறிகுறிகளை தட்டச்சு செய்க...',
      'voiceRecording': 'கேட்கிறது... பேசுங்கள்',
      'send': 'அனுப்பு',
      'uploadTitle': 'மருத்துவ பதிவை பதிவேற்றவும்',
      'uploadSubtitle': 'பரிசோதனை அறிக்கை, மருந்துக் குறிப்பு',
      'chooseFile': 'கோப்பைத் தேர்ந்தெடு',
      'sampleFiles': 'மாதிரி கோப்பைத் தேர்ந்தெடு',
      'analyzingDocument': 'ஆவணம் ஆய்வு செய்யப்படுகிறது...',
      'stepUploaded': 'ஆவணம் பதிவேற்றப்பட்டது',
      'stepExtracted': 'உரை பிரித்தெடுக்கப்பட்டது',
      'stepIdentifying': 'மருத்துவ தகவல் அடையாளம் காணப்படுகிறது',
      'stepPreparing': 'சுருக்கம் தயாரிக்கப்படுகிறது',
      'extractedInfoTitle': 'பிரித்தெடுக்கப்பட்ட மருத்துவ தகவல்',
      'reviewNotice': 'தொடர்வதற்கு முன் தகவலை மதிப்பாய்வு செய்யவும்.',
      'patientInfo': 'நோயாளி தகவல்',
      'diagnoses': 'கண்டறிதல்கள்',
      'medications': 'மருந்துகள்',
      'allergies': 'ஒவ்வாமை',
      'labResults': 'பரிசோதனை முடிவுகள்',
      'previousTreatments': 'முந்தைய சிகிச்சைகள்',
      'medicalHistory': 'மருத்துவ வரலாறு',
      'clinicalSummaryTitle': 'மருத்துவ சுருக்கம்',
      'chiefComplaint': 'முக்கிய புகார்',
      'symptoms': 'அறிகுறிகள்',
      'symptomDetails': 'அறிகுறி விவரங்கள்',
      'currentMedications': 'தற்போதைய மருந்துகள்',
      'attachedRecords': 'இணைக்கப்பட்ட ஆவணங்கள்',
      'additionalNotes': 'கூடுதல் குறிப்புகள்',
      'editInformation': 'திருத்து',
      'confirmSummary': 'உறுதி செய்',
      'shareWithClinician': 'மருத்துவரிடம் பகிருங்கள்',
      'summaryConfirmedNotice': 'சுருக்கம் உறுதி செய்யப்பட்டது.',
      'disclaimer': 'இது ஒரு மருத்துவ அறிக்கை அல்ல, தகவல்களுக்கு மட்டுமே.',
      'settings': 'அமைப்புகள்',
      'privacyData': 'தனியுரிமை',
      'notifications': 'அறிவிப்புகள்',
      'aboutApp': 'பற்றி',
      'logout': 'வெளியேறு',
      'yetToIntegrate': 'விரைவில் இணைக்கப்படும்',
      'consentTitle': 'நோயாளி ஒப்புதல் மற்றும் தனியுரிமை',
      'sessionTitle': 'கியோஸ்க் அமர்வு மற்றும் பிரிவு',
      'allopathicOpd': 'அலோபதி ஓபிடி',
      'ayushOpd': 'ஆயுஷ் ஓபிடி',
      'emergencyTriage': 'அவசர நிலை பரிசோதனை',
      'abhaId': 'ஆபா (ABHA) சுகாதார அடையாள அட்டை',
      'agreeAndProceed': 'ஒப்புக்கொண்டு தொடரவும்',
      'launchSession': 'அமர்வைத் தொடங்கவும்',
    },
    'te': {
      'appName': 'ఆరోగ్యవాణి',
      'tagline': 'మీ ఆరోగ్యం. మీ స్వరం. మెరుగైన సంరక్షణ.',
      'getStarted': 'ప్రారంభించండి',
      'alreadyAccount': 'ఖాతా ఉందా?',
      'welcomeHeadline': 'మీ ఆరోగ్యాన్ని బాగా అర్థం చేసుకుందాం.',
      'welcomeSubtitle':
          'సులభమైన సంభాషణ ద్వారా మీ లక్షణాలు మరియు రికార్డులను పంచుకోండి.',
      'selectLanguage': 'భాషను ఎంచుకోండి',
      'chooseLanguageDesc': 'మీకు అనువైన భాషను ఎంచుకోండి.',
      'continueBtn': 'కొనసాగించండి',
      'profileSetup': 'రోగి ప్రొఫైల్',
      'profileSetupDesc': 'మీ వివరాలను నమోదు చేయండి.',
      'fullName': 'పూర్తి పేరు',
      'age': 'వయస్సు',
      'gender': 'లింగం',
      'phone': 'ఫోన్ నంబర్',
      'email': 'ఈమెయిల్ (ఐచ్ఛికం)',
      'male': 'పురుషుడు',
      'female': 'స్త్రీ',
      'other': 'ఇతర',
      'skip': 'దాటవేయి',
      'home': 'హోమ్',
      'consultation': 'సంప్రదింపు',
      'records': 'రికార్డులు',
      'profile': 'ప్రొఫైల్',
      'goodMorning': 'నమస్కారం',
      'howCanWeHelp': 'ఈరోజు మేము మీకు ఎలా సహాయపడగలం?',
      'startNewConsultation': 'కొత్త సంప్రదింపు ప్రారంభించండి',
      'tellUsWhatExperiencing': 'మీ లక్షణాలను మాకు తెలియజేయండి.',
      'medicalRecordsTitle': 'వైద్య రికార్డులు',
      'uploadedRecordsCount': 'రికార్డులు విశ్లేషించబడ్డాయి',
      'viewRecords': 'రికార్డులు చూడండి',
      'uploadRecord': 'అప్‌లోడ్ చేయండి',
      'previousConsultations': 'గత సంప్రదింపులు',
      'viewSummary': 'సారాంశం చూడండి',
      'quickActions': 'శీఘ్ర చర్యలు',
      'clinicalAssistant': 'క్లినికల్ అసిస్టెంట్',
      'assistantStatus': 'సమాచారం సేకరిస్తోంది',
      'typeYourMessage': 'లక్షణాలను టైప్ చేయండి...',
      'voiceRecording': 'వింటోంది... మాట్లాడండి',
      'send': 'పంపు',
      'uploadTitle': 'రికార్డును అప్‌లోడ్ చేయండి',
      'uploadSubtitle': 'ల్యాబ్ నివేదికలు, ప్రిస్క్రిప్షన్లు',
      'chooseFile': 'ఫైల్ ఎంచుకోండి',
      'sampleFiles': 'నమూనా ఫైల్ ఎంచుకోండి',
      'analyzingDocument': 'పత్రం విశ్లేషిస్తోంది...',
      'stepUploaded': 'పత్రం అప్‌లోడ్ అయింది',
      'stepExtracted': 'వచనం సేకరించబడింది',
      'stepIdentifying': 'వైద్య సమాచారం గుర్తిస్తోంది',
      'stepPreparing': 'సారాంశం తయారుచేస్తోంది',
      'extractedInfoTitle': 'సేకరించిన సమాచారం',
      'reviewNotice': 'కొనసాగే ముందు ఈ సమాచారాన్ని సమీక్షించండి.',
      'patientInfo': 'రోగి సమాచారం',
      'diagnoses': 'నిర్ధారణలు',
      'medications': 'మందులు',
      'allergies': 'అలెర్జీలు',
      'labResults': 'ల్యాబ్ ఫలితాలు',
      'previousTreatments': 'మునుపటి చికిత్సలు',
      'medicalHistory': 'వైద్య చరిత్ర',
      'clinicalSummaryTitle': 'క్లినికల్ సారాంశం',
      'chiefComplaint': 'ప్రధాన సమస్య',
      'symptoms': 'లక్షణాలు',
      'symptomDetails': 'లక్షణాల వివరాలు',
      'currentMedications': 'ప్రస్తుత మందులు',
      'attachedRecords': 'జతచేసిన పత్రాలు',
      'additionalNotes': 'అదనపు గమనికలు',
      'editInformation': 'సవరించు',
      'confirmSummary': 'ధృవీకరించు',
      'shareWithClinician': 'వైద్యునితో పంచుకోండి',
      'summaryConfirmedNotice': 'సారాంశం ధృవీకరించబడింది.',
      'disclaimer': 'ఇది వైద్య నిర్ధారణ కాదు, సహాయక సమాచారం మాత్రమే.',
      'settings': 'సెట్టింగ్‌లు',
      'privacyData': 'గోప్యత',
      'notifications': 'నోటిఫికేషన్‌లు',
      'aboutApp': 'గురించి',
      'logout': 'లాగ్ అవుట్',
      'yetToIntegrate': 'త్వరలో అందుబాటులోకి',
      'consentTitle': 'రోగి సమ్మతి మరియు గోప్యత',
      'sessionTitle': 'కియోస్క్ సెషన్ మరియు విభాగం',
      'allopathicOpd': 'అల్లోపతిక్ ఓపీడీ',
      'ayushOpd': 'ఆయుష్ ఓపీడీ',
      'emergencyTriage': 'అత్యవసర రెడ్-ఫ్లాగ్ స్క్రీనింగ్',
      'abhaId': 'ఆభా (ABHA) హెల్త్ ఐడీ',
      'agreeAndProceed': 'అంగీకరించి కొనసాగించండి',
      'launchSession': 'సెషన్ ప్రారంభించండి',
    },
    'kn': {
      'appName': 'ಆರೋಗ್ಯವಾಣಿ',
      'tagline': 'ನಿಮ್ಮ ಆರೋಗ್ಯ. ನಿಮ್ಮ ಧ್ವನಿ. ಉತ್ತಮ ಆರೈಕೆ.',
      'getStarted': 'ಪ್ರಾರಂಭಿಸಿ',
      'alreadyAccount': 'ಖಾತೆ ಹೊಂದಿದ್ದೀರಾ?',
      'welcomeHeadline': 'ನಿಮ್ಮ ಆರೋಗ್ಯವನ್ನು ಚೆನ್ನಾಗಿ ಅರ್ಥಮಾಡಿಕೊಳ್ಳೋಣ.',
      'welcomeSubtitle':
          'ಸರಳ ಸಂಭಾಷಣೆಯ ಮೂಲಕ ನಿಮ್ಮ ರೋಗಲಕ್ಷಣಗಳು ಮತ್ತು ದಾಖಲೆಗಳನ್ನು ಹಂಚಿಕೊಳ್ಳಿ.',
      'selectLanguage': 'ಭಾಷೆಯನ್ನು ಆರಿಸಿ',
      'chooseLanguageDesc': 'ನಿಮಗೆ ಅನುಕೂಲಕರವಾದ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ.',
      'continueBtn': 'ಮುಂದುವರಿಸಿ',
      'profileSetup': 'ರೋಗಿಯ ಪ್ರೊಫೈಲ್',
      'profileSetupDesc': 'ನಿಮ್ಮ ವಿವರಗಳನ್ನು ನಮೂದಿಸಿ.',
      'fullName': 'ಪೂರ್ಣ ಹೆಸರು',
      'age': 'ವಯಸ್ಸು',
      'gender': 'ಲಿಂಗ',
      'phone': 'ದೂರವಾಣಿ ಸಂಖ್ಯೆ',
      'email': 'ಇಮೇಲ್ (ಐಚ್ಛಿಕ)',
      'male': 'ಪುರುಷ',
      'female': 'ಮಹಿಳೆ',
      'other': 'ಇತರೆ',
      'skip': 'ಈಗಲೇ ಬಿಟ್ಟುಬಿಡಿ',
      'home': 'ಮುಖಪುಟ',
      'consultation': 'ಸಲಹೆ',
      'records': 'ದಾಖಲೆಗಳು',
      'profile': 'ಪ್ರೊಫೈಲ್',
      'goodMorning': 'ನಮಸ್ಕಾರ',
      'howCanWeHelp': 'ನಾವು ಇಂದು ನಿಮಗೆ ಹೇಗೆ ಸಹಾಯ ಮಾಡಬಹುದು?',
      'startNewConsultation': 'ಹೊಸ ಸಲಹೆ ಪ್ರಾರಂಭಿಸಿ',
      'tellUsWhatExperiencing': 'ನಿಮ್ಮ ರೋಗಲಕ್ಷಣಗಳನ್ನು ತಿಳಿಸಿ.',
      'medicalRecordsTitle': 'ವೈದ್ಯಕೀಯ ದಾಖಲೆಗಳು',
      'uploadedRecordsCount': 'ದಾಖಲೆಗಳನ್ನು ವಿಶ್ಲೇಷಿಸಲಾಗಿದೆ',
      'viewRecords': 'ದಾಖಲೆಗಳನ್ನು ನೋಡಿ',
      'uploadRecord': 'ಅಪ್‌ಲೋಡ್ ಮಾಡಿ',
      'previousConsultations': 'ಹಿಂದಿನ ಸಲಹೆಗಳು',
      'viewSummary': 'ಸಾರಾಂಶ ನೋಡಿ',
      'quickActions': 'ತ್ವರಿತ ಕ್ರಿಯೆಗಳು',
      'clinicalAssistant': 'ಕ್ಲಿನಿಕಲ್ ಸಹಾಯಕ',
      'assistantStatus': 'ಮಾಹಿತಿ ಸಂಗ್ರಹಿಸಲಾಗುತ್ತಿದೆ',
      'typeYourMessage': 'ರೋಗಲಕ್ಷಣಗಳನ್ನು ಟೈಪ್ ಮಾಡಿ...',
      'voiceRecording': 'ಕೇಳಿಸಿಕೊಳ್ಳುತ್ತಿದೆ... ಮಾತನಾಡಿ',
      'send': 'ಕಳುಹಿಸಿ',
      'uploadTitle': 'ದಾಖಲೆಯನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ',
      'uploadSubtitle': 'ಲ್ಯಾಬ್ ವರದಿಗಳು, ಪ್ರಿಸ್ಕ್ರಿಪ್ಷನ್‌ಗಳು',
      'chooseFile': 'ಫೈಲ್ ಆಯ್ಕೆಮಾಡಿ',
      'sampleFiles': 'ಮಾದರಿ ಫೈಲ್ ಆಯ್ಕೆಮಾಡಿ',
      'analyzingDocument': 'ದಾಖಲೆಯನ್ನು ವಿಶ್ಲೇಷಿಸಲಾಗುತ್ತಿದೆ...',
      'stepUploaded': 'ದಾಖಲೆ ಅಪ್‌ಲೋಡ್ ಆಗಿದೆ',
      'stepExtracted': 'ಪಠ್ಯ ಹೊರತೆಗೆಯಲಾಗಿದೆ',
      'stepIdentifying': 'ವೈದ್ಯಕೀಯ ಮಾಹಿತಿ ಗುರುತಿಸಲಾಗುತ್ತಿದೆ',
      'stepPreparing': 'ಸಾರಾಂಶ ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ',
      'extractedInfoTitle': 'ಹೊರತೆಗೆಯಲಾದ ಮಾಹಿತಿ',
      'reviewNotice': 'ಮುಂದುವರಿಯುವ ಮುನ್ನ ಪರಿಶೀಲಿಸಿ.',
      'patientInfo': 'ರೋಗಿಯ ಮಾಹಿತಿ',
      'diagnoses': 'ರೋಗನಿರ್ಣಯ',
      'medications': 'ಔಷಧಿಗಳು',
      'allergies': 'ಅಲರ್ಜಿಗಳು',
      'labResults': 'ಲ್ಯಾಬ್ ಫಲಿತಾಂಶಗಳು',
      'previousTreatments': 'ಹಿಂದಿನ ಚಿಕಿತ್ಸೆಗಳು',
      'medicalHistory': 'ವೈದ್ಯಕೀಯ ಇತಿಹಾಸ',
      'clinicalSummaryTitle': 'ಕ್ಲಿನಿಕಲ್ ಸಾರಾಂಶ',
      'chiefComplaint': 'ಮುಖ್ಯ ತೊಂದರೆ',
      'symptoms': 'ರೋಗಲಕ್ಷಣಗಳು',
      'symptomDetails': 'ಲಕ್ಷಣಗಳ ವಿವರ',
      'currentMedications': 'ಪ್ರಸ್ತುತ ಔಷಧಿಗಳು',
      'attachedRecords': 'ಲಗತ್ತಿಸಲಾದ ದಾಖಲೆಗಳು',
      'additionalNotes': 'ಹೆಚ್ಚುವರಿ ಟಿಪ್ಪಣಿಗಳು',
      'editInformation': 'ತಿದ್ದುಪಡಿ',
      'confirmSummary': 'ಖಚಿತಪಡಿಸಿ',
      'shareWithClinician': 'ವೈದ್ಯರೊಂದಿಗೆ ಹಂಚಿಕೊಳ್ಳಿ',
      'summaryConfirmedNotice': 'ಸಾರಾಂಶ ಖಚಿತಪಟ್ಟಿದೆ.',
      'disclaimer': 'ಇದು ವೈದ್ಯಕೀಯ ರೋಗನಿರ್ಣಯವಲ್ಲ, ಸಹಾಯಕ ಮಾಹಿತಿ ಮಾತ್ರ.',
      'settings': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
      'privacyData': 'ಗೌಪ್ಯತೆ',
      'notifications': 'ಅಧಿಸೂಚನೆಗಳು',
      'aboutApp': 'ಕುರಿತು',
      'logout': 'ಲಾಗ್ ಔಟ್',
      'yetToIntegrate': 'ಶೀಘ್ರದಲ್ಲೇ ಸಂಯೋಜಿಸಲಾಗುವುದು',
      'consentTitle': 'ರೋಗಿಯ ಒಪ್ಪಿಗೆ ಮತ್ತು ಗೌಪ್ಯತೆ',
      'sessionTitle': 'ಕಿಯೋಸ್ಕ್ ಅವಧಿ ಮತ್ತು ವಿಭಾಗ',
      'allopathicOpd': 'ಅಲೋಪತಿಕ್ ಒಪಿಡಿ',
      'ayushOpd': 'ಆಯುಷ್ ಒಪಿಡಿ',
      'emergencyTriage': 'ತುರ್ತು ರೆಡ್-ಫ್ಲ್ಯಾಗ್ ಸ್ಕ್ರೀನಿಂಗ್',
      'abhaId': 'ಆಭಾ (ABHA) ಆರೋಗ್ಯ ಐಡಿ',
      'agreeAndProceed': 'ಒಪ್ಪಿ ಮುಂದುವರಿಯಿರಿ',
      'launchSession': 'ಅಧಿವೇಶನ ಪ್ರಾರಂಭಿಸಿ',
    },
  };

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String get appName => translate('appName');
  String get tagline => translate('tagline');
  String get getStarted => translate('getStarted');
  String get alreadyAccount => translate('alreadyAccount');
  String get welcomeHeadline => translate('welcomeHeadline');
  String get welcomeSubtitle => translate('welcomeSubtitle');
  String get selectLanguage => translate('selectLanguage');
  String get chooseLanguageDesc => translate('chooseLanguageDesc');
  String get continueBtn => translate('continueBtn');
  String get profileSetup => translate('profileSetup');
  String get profileSetupDesc => translate('profileSetupDesc');
  String get fullName => translate('fullName');
  String get age => translate('age');
  String get gender => translate('gender');
  String get phone => translate('phone');
  String get email => translate('email');
  String get male => translate('male');
  String get female => translate('female');
  String get other => translate('other');
  String get skip => translate('skip');
  String get home => translate('home');
  String get consultation => translate('consultation');
  String get records => translate('records');
  String get profile => translate('profile');
  String get goodMorning => translate('goodMorning');
  String get howCanWeHelp => translate('howCanWeHelp');
  String get startNewConsultation => translate('startNewConsultation');
  String get tellUsWhatExperiencing => translate('tellUsWhatExperiencing');
  String get medicalRecordsTitle => translate('medicalRecordsTitle');
  String get uploadedRecordsCount => translate('uploadedRecordsCount');
  String get viewRecords => translate('viewRecords');
  String get uploadRecord => translate('uploadRecord');
  String get previousConsultations => translate('previousConsultations');
  String get viewSummary => translate('viewSummary');
  String get quickActions => translate('quickActions');
  String get clinicalAssistant => translate('clinicalAssistant');
  String get assistantStatus => translate('assistantStatus');
  String get typeYourMessage => translate('typeYourMessage');
  String get voiceRecording => translate('voiceRecording');
  String get send => translate('send');
  String get uploadTitle => translate('uploadTitle');
  String get uploadSubtitle => translate('uploadSubtitle');
  String get chooseFile => translate('chooseFile');
  String get sampleFiles => translate('sampleFiles');
  String get analyzingDocument => translate('analyzingDocument');
  String get stepUploaded => translate('stepUploaded');
  String get stepExtracted => translate('stepExtracted');
  String get stepIdentifying => translate('stepIdentifying');
  String get stepPreparing => translate('stepPreparing');
  String get extractedInfoTitle => translate('extractedInfoTitle');
  String get reviewNotice => translate('reviewNotice');
  String get patientInfo => translate('patientInfo');
  String get diagnoses => translate('diagnoses');
  String get medications => translate('medications');
  String get allergies => translate('allergies');
  String get labResults => translate('labResults');
  String get previousTreatments => translate('previousTreatments');
  String get medicalHistory => translate('medicalHistory');
  String get clinicalSummaryTitle => translate('clinicalSummaryTitle');
  String get chiefComplaint => translate('chiefComplaint');
  String get symptoms => translate('symptoms');
  String get symptomDetails => translate('symptomDetails');
  String get currentMedications => translate('currentMedications');
  String get attachedRecords => translate('attachedRecords');
  String get additionalNotes => translate('additionalNotes');
  String get editInformation => translate('editInformation');
  String get confirmSummary => translate('confirmSummary');
  String get shareWithClinician => translate('shareWithClinician');
  String get summaryConfirmedNotice => translate('summaryConfirmedNotice');
  String get disclaimer => translate('disclaimer');
  String get settings => translate('settings');
  String get privacyData => translate('privacyData');
  String get notifications => translate('notifications');
  String get aboutApp => translate('aboutApp');
  String get logout => translate('logout');
  String get yetToIntegrate => translate('yetToIntegrate');
  String get consentTitle => translate('consentTitle');
  String get sessionTitle => translate('sessionTitle');
  String get allopathicOpd => translate('allopathicOpd');
  String get ayushOpd => translate('ayushOpd');
  String get emergencyTriage => translate('emergencyTriage');
  String get abhaId => translate('abhaId');
  String get agreeAndProceed => translate('agreeAndProceed');
  String get launchSession => translate('launchSession');
}
