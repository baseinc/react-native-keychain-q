# react-native-keychain-q

Keychain Wrapper for React Native.


- [react-native-keychain-q](#react-native-keychain-q)
  - [Getting started](#getting-started)
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

## Getting started

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
  'bob',
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
