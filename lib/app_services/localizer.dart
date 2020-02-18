
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';



// localization
class DemoLocalizations {
  DemoLocalizations(this.locale);

  final Locale locale;

  static DemoLocalizations of(BuildContext context) {
    return Localizations.of<DemoLocalizations>(context, DemoLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      "Services Menu": "Services Menu",
      "Requests": "Requests",
      "History": "History",
      "My Profile": "My Profile",
      "Help": "Help",
      "Log out": "Log out",
      "Full names": "Full names",
      "About": "About",
      "Telephone number":"Telephone number",
      "Categories": "Categories",
      "Next":"Next",
      "Confirm": "Confirm",
      "Price": "Price",
      "Location": "Location",
      "Service": "Service",
      "Request": "Request",
      "Request Sent": "Request sent",
      "Success message": "You will be notified soon from your service provider",
      "Cancel Request": "Cancel Request",
      "Requests pending": "Requests pending",
      "Not Available": "Not Available",
      "QandA": "For any questions or inquiries, please contact us at",
      "Stylist Profile": "",
      "Or":"OR",
      "Q&A": "For any questions or feedback please contact us",
      "Stylist Profile":"Stylist Profile",
      "Processing": "Processing...",
      "back": "Back",
      "No requests": "No requests Made",
      "provider_details_not_available": "No services available for the this service provider. Please try another one",
      "OK": "OK",
      "Canceled Successfully": "Request Canceled Successfully",
      "make_request": "Request",
      "welcome": "Great! Let\'s get to know you more",
      "finish": "FINISH",
      "male": "MALE",
      "female": "Female",
      "gender_required": "Gender required",
      "full_name_required":"Full name required",
      "nationalID_required": "National ID number required",
      "location_required": "Location required",
      "phoneNumber_required": "Phone Number required",
      "nationalID": "National ID",
      "choose_language": "Welcome to E-salon please choose your language",
      "sign_up": "CREATE ACCOUNT"
    },
    'pt': {
      "Services Menu": "Menu Serviços",
      "Requests": "Solicitações de",
      "History": "História",
      "My Profile": "Meu perfil",
      "Help": "Socorro",
      "Log out": "Sair",
      "Profile": "Perfil",
      "Full names": "Nomes completos",
      "About": "Sobre",
      "Telephone number": "Número de telefone",
      "Categories": "Categorias",
      "Next": "Próximo",
      "Confirm": "Confirme",
      "Price": "Preço",
      "Location": "Localização",
      "Service":"Serviço",
      "Request":"Pedido",
      "Request Sent": "Pedido enviado",
      "Success message": "Você será notificado em breve com o seu provedor de serviços",
      "Cancel Request": "Cancelar pedido",
      "Requests pending": "Pedidos pendentes",
      "Or":"Ou",
      "Q&A": "Para qualquer dúvida ou feedback entre em contato conosco",
      "Stylist Profile":"Perfil do estilista",
      "Processing": "Em processamento...",
      "back": "De volta",
      "No requests": "Sem pedidos",
      "provider_details_not_available": "Oops detalhes do provedor de serviços não disponíveis. Tente outro",
      "OK": "Está bem",
      "Canceled Successfully": "Cancelado com sucesso",
      "make_request": "Pedido",
      "welcome": "Ótimo! Vamos te conhecer mais",
      "finish": "TERMINAR",
      "male": "MASCULINO",
      "female": "FÊMEA",
      "gender_required": "Sexo requerido",
      "full_name_required":"Nomes completos necessários",
      "nationalID": "ID nacional obrigatório",
      "location_required": "Localização requerida",
      "phoneNumber_required": "Número de telefone requerido",
      "nationalID": "Número de Identificação Nacional",
      "choose_language": "Bem-vindo ao E-salon por favor escolha o seu idioma",
      "sign_up": "Inscrever-se"
    },
    'zh': {
      "Services Menu": "服务",
      "Requests": "要求",
      "History": "历史",
      "My Profile": "我的简历",
      "Help": "救命",
      "Log out": "登出",
      "Profile": "轮廓",
      "Full names": "全名",
      "About": "关于",
      "Telephone number":"电话号码",
      "Categories": "分类",
      "Next":"下一个",
      "Confirm": "确认",
      "Price": "价钱",
      "Location": "地点",
      "Service": "服务",
      "Request": "请求",
      "Request Sent": "请求已发送",
      "Success message": "成功的消息",
      "Cancel Request": "取消请求",
      "Requests pending": "请求待处理",
      "Not Available": "无法使用",
      "Q&A": "如有任何问题或反馈，请联系我们",
      "Or": "要么",
      "Stylist Profile": "造型师简介",
      "Processing": "处理...",
      "back": "Back",
      "No requests": "没有要求",
      "make_request": "请求",
      "provider_details_not_available": "造型师的细节不可用",
      "OK": "好",
      "Canceled Successfully": "取消成功",
      "welcome": "大！让我们更多地了解你",
      "finish": "完",
      "male": "男",
      "female": "女",
      "gender_required": "需要性别",
      "full_name_required":"需要全名",
      "nationalID_required": "需要国民身份证",
      "location_required": "需要的位置",
      "phoneNumber_required": "需要电话号码",
      "nationalID": "国家注册号码",
      "choose_language": "欢迎来到电子沙龙请选择您的语言",
      "sign_up": "注册"
    },
    'sw': {
      "Services Menu": "Menyu ya Huduma",
      "Requests": "Maombi",
      "History": "Historia",
      "My Profile": "Profaili yangu",
      "Help": "Msaada",
      "Log out": "Ingia nje",
      "Profile": "Profaili",
      "Full names": "Majina kamili",
      "About": "Kuhusu",
      "Telephone number":"Nambari ya simu",
      "Categories": "Jamii",
      "Next":"Ifuatayo",
      "Confirm": "Thibitisha",
      "Price": "Bei",
      "Location": "Eneo",
      "Service": "Huduma",
      "Request": "Omba",
      "Request Sent": "Ombi limetumwa",
      "Success message": "Ujumbe wa mafanikio",
      "Cancel Request": "Futa ombi",
      "Requests pending": "Maombi yanayotumiwa",
      "Stylist Profile": "Profaili wa Stylist",
      "Or":"Au",
      "Q&A": "Kwa maswali yoyote au maswali, tafadhali wasiliana nasi saa",
      "Processing": "Usindikaji...",
      "back": "Rudi",
      "No requests": "Hakuna maombi",
      "provider_details_not_available":"Hakuna huduma zinazopatikana kwa mtoa huduma hii. Tafadhali jaribu mwingine",
      "OK": "Sawa",
      "Canceled Successfully": "Imepigwa kwa Ufanisi",
      "make_request": "Fazer pedido",
      "welcome": "Kubwa! Hebu tujue zaidi",
      "finish": "KUMALIZA",
      "male": "KIUME",
      "female": "KIKE",
      "gender_required": "insia ya lazima",
      "full_name_required":"Jina kamili linahitajika",
      "nationalID_required": "ID ya Taifa inahitajika",
      "location_required": "Eneo linalohitajika",
      "phoneNumber_required": "Nambari ya simu inahitajika",
      "NationalID": "Kitambulisho cha Taifa",
      "choose_language" : "Karibu E-saloni tafadhali chagua lugha yako",
      "sign_up": "Ingia"
    },
    'ar': {
      "Services Menu": "قائمة الخدمات",
      "Requests": "طلبات",
      "History": "التاريخ",
      "My Profile": "ملفي",
      "Help": "مساعدة",
      "Log out": "الخروج",
      "Profile": "الملف الشخصي",
      "Full names": "الأسماء الكاملة",
      "About": "حول",
      "Telephone number": "رقم هاتف",
      "Categories": "الاقسام",
      "Next": "التالى",
      "Confirm": "تؤكد",
      "Price": "السعر",
      "Location": "موقعك",
      "Service":"الخدمات",
      "Request":"طلب",
      "Request Sent": "تم ارسال الطلب",
      "Success message": "سيتم إخطارك قريبًا من مزوالخدمة الخاص بك ",
      "Cancel Request": "إلغاء الطلب",
      "Requests pending": "طلبات معلقة",
      "Or":"أو",
      "Q&A": "لأية أسئلة أو ملاحظات يرجى الاتصال بنا",
      "Stylist Profile":"المصمم الشخصي",
      "Processing": "معالجة...",
      "back": "الى الخلف",
      "No requests": "لا طلبات",
      "provider_details_not_available": "لا توجد خدمات متاحة لمزود الخدمة هذا. يرجى محاولة واحدة أخرى",
      "OK": "حسنا",
      "Canceled Successfully": "تم الإلغاء بنجاح",
      "make_request": "قدم طلبا",
      "welcome": "عظيم! دعنا نتعرف عليك أكثر",
      "finish": "إنهي",
      "male": "الذكر",
      "female": "إناثا",
      "gender_required": "الجنس المطلوب",
      "full_name_required":"الاسم الكامل مطلوب",
      "nationalID_required_": "رقم الهوية الوطنية المطلوبة",
      "location_required": "الموقع مطلوب",
      "phoneNumber_required": "رقم الهاتف مطلوب",
      "nationalID": "رقم الهوية الوطنية",
      "choose_language": "مراختيار لغتكحبًا بكم في صالون E- يرجى",
      "sign_up": "سجل"
    },
    'af':  {
      "Services Menu": "Dienste Spyskaart",
      "Requests": "Versoeke",
      "History": "Geskiedenis",
      "My Profile": "My profiel",
      "Help": "Help",
      "Log out": "Teken uit",
      "Full names": "Volle name",
      "About": "Oor",
      "Telephone number":"Telefoon nommer",
      "Categories": "Kategorieë",
      "Next":"Volgende",
      "Confirm": "Bevestig",
      "Price": "Prys",
      "Location": "Plek",
      "Service": "Diens",
      "Request": "Versoek",
      "Request Sent": "Versoek gestuur",
      "Success message": "U sal binnekort van u diensverskaffer in kennis gestel word",
      "Cancel Request": "Kanselleer versoek",
      "Requests pending": "Versoeke hangende",
      "Not Available": "Nie beskikbaar nie",
      "QandA": "Vir enige vrae of navrae, kontak ons ​​asseblief by",
      "Or":"Of",
      "Q&A": "Vir enige vrae of terugvoer kontak ons ​​asseblief",
      "Stylist Profile":"Stylist Profiel",
      "Processing": "Verwerking...",
      "back": "Terug",
      "No requests": "Geen versoeke",
      "provider_details_not_available": "Geen dienste beskikbaar vir hierdie diensverskaffer nie. Probeer asseblief 'n ander een",
      "OK": "OK",
      "Canceled Successfully": "Versoek gekanselleer suksesvol",
      "make_request": "Versoek",
      "welcome": "Groot! Kom ons leer jou mee",
      "finish": "AFWERKING",
      "male": "MANLIK",
      "female": "VROULIKE",
      "gender_required": "Geslag benodig",
      "full_name_required":"Volle naam benodig",
      "nationalID_required": "Nasionale ID nommer vereis",
      "location_required": "Plek benodig",
      "phoneNumber_required": "Telefoonnommer benodig",
      "nationalID": "Nasionale ID",
      "choose_language": "Welkom by E-salon, kies asseblief u taal",
      "sign_up": "SKEP REKENING"
    }
  };

  String get serviceMenu {
    return _localizedValues[locale.languageCode]['Services Menu'];
  }
  String get requests {
    return _localizedValues[locale.languageCode]['Requests'];
  }
  String get history {
    return _localizedValues[locale.languageCode]['History'];
  }
  String get profile {
    return _localizedValues[locale.languageCode]['My Profile'];
  }
  String get help {
    return _localizedValues[locale.languageCode]['Help'];
  }
  String get logOut {
    return _localizedValues[locale.languageCode]['Log out'];
  }
  String get Profile {
    return _localizedValues[locale.languageCode]['Profile'];
  }
  String get fullNames {
    return _localizedValues[locale.languageCode]['Full names'];
  }
  String get about {
    return _localizedValues[locale.languageCode]['About'];
  }
  String get telephone {
    return _localizedValues[locale.languageCode]['Telephone number'];
  }
  String get categories {
    return _localizedValues[locale.languageCode]['Categories'];
  }
  String get next {
    return _localizedValues[locale.languageCode]['Next'];
  }
  String get confirm {
    return _localizedValues[locale.languageCode]['Confirm'];
  }
  String get Price {
    return _localizedValues[locale.languageCode]['Price'];
  }
  String get Location {
    return _localizedValues[locale.languageCode]['Location'];
  }
  String get Service {
    return _localizedValues[locale.languageCode]['Service'];
  }
  String get Request {
    return _localizedValues[locale.languageCode]['Request'];
  }
  String get requestSent {
    return _localizedValues[locale.languageCode]['Request Sent'];
  }
  String get successMessage {
    return _localizedValues[locale.languageCode]['Success message'];
  }
  String get cancelRequest {
    return _localizedValues[locale.languageCode]['Cancel Request'];
  }
  String get requestsPending {
    return _localizedValues[locale.languageCode]['Requests pending'];
  }
  String get notAvailable {
    return _localizedValues[locale.languageCode]['Not Available'];
  }

  String get QandA {
    return _localizedValues[locale.languageCode]['Q&A'];
  }
  String get Or {
    return _localizedValues[locale.languageCode]['Or'];
  }
  String get stylistProfile {
    return _localizedValues[locale.languageCode]['styler'];
  }
  String get back {
    return _localizedValues[locale.languageCode]['back'];
  }
  String get processing {
    return _localizedValues[locale.languageCode]['Processing'];
  }
  String get noRequests {
    return _localizedValues[locale.languageCode]['No requests'];
  } //provider_details_not_available
  String get make_request {
    return _localizedValues[locale.languageCode]['make_request'];
  }

  String get provider_details_not_available {
    return _localizedValues[locale.languageCode]['provider_details_not_available'];
  }
  String get canceledSuccessfully {
    return _localizedValues[locale.languageCode]['Canceled Successfully'];
  }
  String get okay {
    return _localizedValues[locale.languageCode]['OK'];
  }
  String get welcome {
    return _localizedValues[locale.languageCode]['welcome'];
  }
  String get finish {
    return _localizedValues[locale.languageCode]['finish'];
  }
  String get male {
    return _localizedValues[locale.languageCode]['male'];
  }
  String get female {
    return _localizedValues[locale.languageCode]['female'];
  }
  String get gender_required {
    return _localizedValues[locale.languageCode]['gender_required'];
  }

  String get full_name_required {
    return _localizedValues[locale.languageCode]['full_name_required'];
  }


  String get nationalID {
    return _localizedValues[locale.languageCode]['nationalID'];
  }
  String get nationalID_required {
    return _localizedValues[locale.languageCode]['nationalID_required'];
  }


  String get  location_required {
    return _localizedValues[locale.languageCode][' location_required'];
  }

  String get  phoneNumber_required {
    return _localizedValues[locale.languageCode][' phoneNumber_required'];
  }
  String get  choose_language {
    return _localizedValues[locale.languageCode]['choose_language'];
  }

  String get  sign_up {
    return _localizedValues[locale.languageCode]['sign_up'];
  }
}


class DemoLocalizationsDelegate extends LocalizationsDelegate<DemoLocalizations> {
  // final Locale newLocale; {this.newLocale}

  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh', 'pt', 'sw'].contains(locale.languageCode);

  @override
  Future<DemoLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<DemoLocalizations>(DemoLocalizations(locale));
  }

  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}