import 'package:local_auth/local_auth.dart';

class LocalAuthServices {
final LocalAuthentication auth = LocalAuthentication();

Future<bool> authenticate() async{
  try{
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();
    if(!canCheckBiometrics && !isDeviceSupported){
      return false;
    }
    bool authenticated = await auth.authenticate(
        localizedReason:"Use Face ID / Touch ID to view secure data",
      biometricOnly: false,
      persistAcrossBackgrounding: true,
    );
 
    return authenticated;

  }catch(e){
    return false;
  }
}
}