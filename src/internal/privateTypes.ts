import {
    KeychainErrorCodes,
    BiometryType,
    SaveOptions,
    Options,
    InternetCredentials,
    DeviceOwnerAuthPolicy,
    AccountOptions,
} from './types';

/**
 * constantsToExport
 */
type NativeConstants = Readonly<{
    authenticationUserCanceledCode: number;
    keychainErrorCodes: { [K in KeychainErrorCodes]: string };
}>;

type NativeMethods = Readonly<{
    fetchCanUseDeviceAuthPolicy: (
        policy: DeviceOwnerAuthPolicy
    ) => Promise<boolean>;
    fetchSupportedBiometryType: () => Promise<BiometryType>;
    saveInternetPassword: (
        server: string,
        account: string,
        password: string,
        options: SaveOptions
    ) => Promise<boolean>;
    removeInternetPassword: (
        server: string,
        account: string,
        options: Options
    ) => Promise<boolean>;
    containsAnyInternetPassword: (
        server: string,
        options: AccountOptions
    ) => Promise<boolean>;
    findInternetPassword: (
        server: string,
        options: AccountOptions
    ) => Promise<InternetCredentials | undefined>;
    resetInternetPasswords: (
        server: string | undefined,
        options: Options
    ) => Promise<boolean>;
    retrieveInternetPasswords: (
        server: string | undefined,
        options: AccountOptions
    ) => Promise<InternetCredentials[]>;
}>;

export type KeychainNativeModule = NativeConstants & NativeMethods & {};
