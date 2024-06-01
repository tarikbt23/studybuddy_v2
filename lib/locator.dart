import 'package:get_it/get_it.dart';
import 'package:study_buddy/service/auth_service.dart';
import 'package:study_buddy/service/provider/auth_provider.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<SBAuthProvider>(SBAuthProvider());
  locator.registerSingleton<AuthService>(AuthService());
}
