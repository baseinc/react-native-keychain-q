# react-native-keychain-q

Keychain Wrapper for React Native.


- [react-native-keychain-q](#react-native-keychain-q)
  - [Getting started](#getting-started)
    - [Prepare](#prepare)
    - [Installation](#installation)
    - [Mostly automatic installation](#mostly-automatic-installation)
      - [Using React Native >= 0.60](#using-react-native--060)
      - [Using React Native < 0.60 or skip auto-linking](#using-react-native--060-or-skip-auto-linking)
  - [Requirements](#requirements)
  - [Usage](#usage)
    - [API](#api)
      - [saveInternetPassword()](#saveinternetpassword)
      - [removeInternetPassword()](#removeinternetpassword)
      - [containsAnyInternetPassword()](#containsanyinternetpassword)
      - [findInternetPassword()](#findinternetpassword)
      - [fetchCanUseDeviceAuthPolicy()](#fetchcanusedeviceauthpolicy)
      - [fetchSupportedBiometryType()](#fetchsupportedbiometrytype)
      - [getBiometryTypeLabel()](#getbiometrytypelabel)
      - [resetInternetPasswords()](#resetinternetpasswords)
      - [retrieveInternetPasswords()](#retrieveinternetpasswords)
  - [Types](#types)
    - [Options](#options)
    - [InternetCredentials](#internetcredentials)
    - [ErrorCodes](#errorcodes)

## Getting started


### Prepare

**Since the native code for this module is written in Swift, you need to add a bridging-header.**

Because it includes Swift code, you need to use both Objective-C and Swift.
Don't worry. Just add bridging-header file.

https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_objective-c_into_swift

1. Add some Swift file(e.g. Empty.Swift) in your xcode project.
2. Xcode offers to create this header.
3. If you accept, Xcode creates the bridging header file and automatically configures build settings.

### Installation

using yarn:

`$ yarn add react-native-keychain-q`

or npm:

`$ npm install react-native-keychain-q --save`

### Mostly automatic installation

#### Using React Native >= 0.60
Linking the package manually is not required anymore with [Autolinking](https://github.com/react-native-community/cli/blob/master/docs/autolinking.md).

Run `pod install` to install iOS dependencies.
`$ cd ios && pod install && cd ..`

#### Using React Native < 0.60 or skip auto-linking

You need to run this command, and then `pod install` after running the below link command inside your `ios` folder.
`$ react-native link react-native-keychain-q`

## Requirements

`>= iOS 9.0` and `>= React Native 0.59.0`.

## Usage
**Import an entire module's contents**
```typescript
// 1. Import an entire module's contents. using module name as a namespace.
import * as keychain from 'react-native-keychain-q';

// To call `saveInternetPassword()`.
await keychain.saveInternetPassword(server, account, password, options);

try {
  // Retrieve a credentials
  const credentials: InternetCredentials | undefined = await keychain.findInternetPassword(server, account, options);
} catch (e) {
  if (keychainErrorInfo(e)) {
    if (e.code === keychainErrorCode('userCanceled')) {
      // failed by user canceled.
    }
  }
}
```
**Import multiple exports from module**
```typescript
// 2. Import selective exports from module
import { saveInternetPassword, findInternetPassword } from 'react-native-keychain-q';

// Do the same as the first example
await saveInternetPassword(server, account, password, options);
```

### API

#### saveInternetPassword()

Save the internet account and password.

Examples
```typescript
import * as keychain from 'react-native-keychain-q';

await keychain.saveInternetPassword(
  // pass the string of URL or host(e.g. keychain-q.example.com)
  'https://keychain-q.example.com',
  // account
  'bob',
  // password
  'password',
  // SaveOptions
  {
    accessGroup: 'com.example.keychain-q.shared',
    // Pre-check the biometrics of device with LocalAuthentication.framework
    deviceOwnerAuthPolicy: 'biometrics',
    // Restricting keychain item
    accessible: 'afterFirstUnlockThisDeviceOnly',
    // Access control flags to retrieve a keychain item
    accessControls: ['userPresence'],
  });
```

#### removeInternetPassword()

Remove the internet password from Keychain.

Examples
```typescript
import * as keychain from 'react-native-keychain-q';

await Keychain.removeInternetPassword(
  'https://keychain-q.example.com',
  'bob',
  {
    accessGroup: 'com.example.keychain-q.shared'
  });
```

#### containsAnyInternetPassword()

Check if the account for server. if an entry exists, it returns to `true`.

Examples
```typescript
import * as keychain from 'react-native-keychain-q';

const contained = await Keychain.containsAnyInternetPassword(
  'https://keychain-q.example.com',
  {
    account: 'bob',
    accessGroup: 'com.example.keychain-q.shared',
  });
// -> true
```

#### findInternetPassword()

Retrieve the credentials. If the item protected, it requires authentication by user.

Examples
```typescript
import * as keychain from 'react-native-keychain-q';

const credentials: InternetCredentials | undefined = await Keychain.findInternetPassword(
  'https://keychain-q.example.com',
  {
    account: 'bob',
    accessGroup: 'com.example.keychain-q.shared',
  });
// -> { server: 'https://keychain-q.example.com', account: 'bob',  password: 'pass' };
```

#### fetchCanUseDeviceAuthPolicy()

Check if it is supported that the type of local authentication policy is supported on the device with the settings. it returns `true` if supported.


| Parameter    | Type                                                       | Description                                                 |
| ------------ | ---------------------------------------------------------- | ----------------------------------------------------------- |
| `biometrics` | Same as `LAPolicy.deviceOwnerAuthenticationWithBiometrics` | User authentication with biometry.                          |
| `any`        | Same as `LAPolicy.deviceOwnerAuthentication`               | User authentication with biometry, or the device passcode.. |

Examples
```typescript
import * as keychain from 'react-native-keychain-q';

const evaluated = await Keychain.fetchCanUseDeviceAuthPolicy('biometrics');
// -> true
```

#### fetchSupportedBiometryType()

Retrieve the type of biometry of the device.

| Result    | Description                                                  |
| --------- | ------------------------------------------------------------ |
| `touchID` | Touch ID supported on the device.                            |
| `faceID`  | Face ID supported on the device.                             |
| `none`    | Nothing of any biometry type.                                |
| `unknown` | Always this parameter if Keychain is not supported platform. |

Examples
```typescript
import * as keychain from 'react-native-keychain-q';

const biometryType = await Keychain.fetchSupportedBiometryType();
// -> faceID
```

#### getBiometryTypeLabel()

Get the label associated the biometry type.

| Result    | Label      |
| --------- | ---------- |
| `touchID` | `Touch ID` |
| `faceID`  | `Face ID`  |
| `none`    | undefined  |
| `unknown` | undefined  |

Examples
```typescript
import * as keychain from 'react-native-keychain-q';

const label = Keychain.getBiometryTypeLabel('faceID');
// -> Face ID
```

#### resetInternetPasswords()

Remove multiple items of internet password.

Examples
```typescript
import * as keychain from 'react-native-keychain-q';

await Keychain.resetInternetPasswords('https://keychain-q.example.com');
```

#### retrieveInternetPasswords()

Retrieve multiple credentials of internet password.

Examples
```typescript
import * as keychain from 'react-native-keychain-q';

const collection = await Keychain.retrieveInternetPasswords('https://keychain-q.example.com');
// -> [{ server: 'https://keychain-q.example.com', account: 'bob',  password: 'pass' }, ...]
```

## Types

### Options

Describes the options to request API.

| Parameter               | Type                         | Description                                                                                                                                                      | Default        |
| ----------------------- | ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- |
| `accessGroup`           | `string`                     | (Common option) A key whose value is a string indicating the access group an item is in. Not required by default. sharing access to keychain items in app group. |                |
| `authenticationPrompt`  | `string`                     | (Common option) Custom authentication Prompt message to display if the item protected. It will be displayed in case of Touch ID or passcode authentication.      |                |
| `deviceOwnerAuthPolicy` | `biometrics \| any \| none`  | (Common option) The policy of biometry or passcode to pre-check local authentication. currently, it is passed to only `saveInternetPassword()`                   |                |
| `accessible`            | `Accessible`                 | (use `saveInternetPassword()`) The accessibility value to access to the data in keychain.                                                                        | `whenUnlocked` |
| `accessControls`        | `AccessControlConstraints[]` | (use `saveInternetPassword()`) The access controls for the item in keychain.                                                                                     |                |
| `server`                | `string`                     | Associated server for the item in Keychain.                                                                                                                      |                |
| `account`               | `string`                     | Associated account for the item in Keychain.                                                                                                                     |
**Accessible**

| Parameter                        | Description                                                 |
| -------------------------------- | ----------------------------------------------------------- |
| `whenPasscodeSetThisDeviceOnly`  | Same as `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`.  |
| `whenUnlockedThisDeviceOnly`     | Same as `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.     |
| `whenUnlocked`                   | Same as `kSecAttrAccessibleWhenUnlocked`.                   |
| `afterFirstUnlockThisDeviceOnly` | Same as `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`. |
| `afterFirstUnlock`               | Same as `kSecAttrAccessibleAfterFirstUnlock`.               |

**AccessControlConstraints**

| Parameter             | Description                                                                                                 |
| --------------------- | ----------------------------------------------------------------------------------------------------------- |
| `devicePasscode`      | https://developer.apple.com/documentation/security/secaccesscontrolcreateflags/1394326-devicepasscode.      |
| `biometryAny`         | https://developer.apple.com/documentation/security/secaccesscontrolcreateflags/2937191-biometryany.         |
| `biometryCurrentSet`  | https://developer.apple.com/documentation/security/secaccesscontrolcreateflags/2937192-biometrycurrentset.  |
| `userPresence`        | https://developer.apple.com/documentation/security/secaccesscontrolcreateflags/1392879-userpresence.        |
| `applicationPassword` | https://developer.apple.com/documentation/security/secaccesscontrolcreateflags/1617930-applicationpassword. |

### InternetCredentials

Describes the structure of credentials  to resolve from Keychain.

| Parameter    | Type                | Description                                                  | Default |
| ------------ | ------------------- | ------------------------------------------------------------ | ------- |
| `server`     | `string (required)` | Associated host(e.g. `keychain-q.example.com`) for the item. |         |
| `port`       | `Int (optional)`    | Associated port(e.g. `8081`) for the item.                   |         |
| `account`    | `string (required)` | The item's account name.                                     |         |
| `password`   | `string (required)` | The item's data.                                             |         |
| `createdAt`  | `number`            | The item's creation date.                                    |         |
| `modifiedAt` | `number`            | The item's last modification date.                           |         |

### ErrorCodes

| Key                      | Description                                                         |
| ------------------------ | ------------------------------------------------------------------- |
| `userCanceled`           | When user canceled the operation.                                   |
| `noPassword`             | The password not found.                                             |
| `notAvailable`           | Unavailable.                                                        |
| `inputPasswordInvalid`   |                                                                     |
| `inputValueInvalid`      | When the invalid input data was passed.                             |
| `unexpectedPasswordData` | The item found but it is unavailable for some reason.               |
| `unhandledException`     | Keychain returns [OSStatus](https://www.osstatus.com/) of an error. |
