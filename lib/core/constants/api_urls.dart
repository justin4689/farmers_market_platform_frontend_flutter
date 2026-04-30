class ApiUrls {
  ApiUrls._();

  static const String baseUrl = 'http://10.0.2.2:8000/api';

  //http://10.0.2.2:8000/api LOCAL API URL 

  
  // static const String baseUrl = 'http://13.51.177.195/api';

  // Auth
  static const String login = '/login';
  static const String logout = '/logout';

  // Farmers
  static const String farmersSearch = '/farmers/search';
  static String farmerById(int id) => '/farmers/$id';
  static const String createFarmer = '/farmers';
  static String farmerDebts(int id) => '/farmers/$id/debts';

  // Products
  static const String categories = '/categories';
  static const String products = '/products';

  // Transactions
  static const String createTransaction = '/transactions';

  // Repayments
  static const String createRepayment = '/repayments';
}
