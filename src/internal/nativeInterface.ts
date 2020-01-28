import { NativeModules, Platform } from 'react-native';
import { KeychainNativeModule } from './privateTypes';

const KeychainQ: KeychainNativeModule | undefined = NativeModules.KeychainQ;

if (!KeychainQ) {
    if (Platform.OS === 'ios') {
        throw new Error(
            `react-native-keychain-q: NativeModule.KeychainQ is null. To fix this issue try these steps:

            • Run \`react-native link react-native-keychain-q\` in the project root.
            • Rebuild and re-run the app.
            • If you are using CocoaPods on iOS, run \`pod install\` in the \`ios\` directory and then rebuild and re-run the app. You may also need to re-open Xcode to get the new pods.
            • Check that the library was linked correctly when you used the link command by running through the manual installation instructions in the README.
            * If you are getting this error while unit testing you need to mock the native module. Follow the guide in the README.

            If none of these fix the issue, please open an issue on the Github repository: https://github.com/baseinc/react-native-keychain-q`
        );
    }
}

export default KeychainQ as KeychainNativeModule;
