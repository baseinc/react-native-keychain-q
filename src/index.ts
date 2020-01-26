import Keychain from './internal/nativeInterface';
import {
    DeviceOwnerAuthPolicy,
    BiometryType,
    SaveOptions,
    Options,
    AccountOptions,
    KeychainErrorCodes,
    ServerOptions,
    ServerAccountOptions,
    InternetCredentials,
} from './internal/types';
import { useOnMount } from './internal/hooks';
import { useCallback } from 'react';

export function keychainErrorCode(name: KeychainErrorCodes) {
    if (Keychain) {
        return Keychain.keychainErrorCodes[name];
    }
    return 'UNKNOWN';
}

export async function fetchCanUseDeviceAuthPolicy(
    policy: DeviceOwnerAuthPolicy = 'any'
) {
    if (Keychain) {
        return await Keychain.fetchCanUseDeviceAuthPolicy(policy);
    }
    return false;
}

export async function fetchSupportedBiometryType(): Promise<
    BiometryType | 'unknown'
> {
    if (Keychain) {
        return await Keychain.fetchSupportedBiometryType();
    }
    return 'unknown';
}

export async function saveInternetPassword(
    server: string,
    account: string,
    password: string,
    options: SaveOptions = {}
) {
    if (Keychain) {
        return await Keychain.saveInternetPassword(
            server,
            account,
            password,
            options
        );
    }
    return false;
}

export async function removeInternetPassword(
    server: string,
    account: string,
    options: Options = {}
) {
    if (Keychain) {
        return await Keychain.removeInternetPassword(server, account, options);
    }
    return false;
}

export async function containsAnyInternetPassword(
    server: string,
    options: AccountOptions = {}
) {
    if (Keychain) {
        return await Keychain.containsAnyInternetPassword(server, options);
    }
    return false;
}

export async function findInternetPassword(
    server: string,
    options: AccountOptions = {}
) {
    if (Keychain) {
        return await Keychain.findInternetPassword(server, options);
    }
    return undefined;
}

export async function resetInternetPasswords(options: ServerOptions = {}) {
    if (Keychain) {
        const { server, ...rest } = options;
        return await Keychain.resetInternetPasswords(server, rest);
    }
    return false;
}

export async function retrieveInternetPasswords(
    options: ServerAccountOptions = {}
) {
    if (Keychain) {
        const { server, ...rest } = options;
        const response = await Keychain.retrieveInternetPasswords(server, rest);
        return response.length > 0 ? response : undefined;
    }
}

export function useCanUseDeviceAuthPolicy(
    policy: DeviceOwnerAuthPolicy = 'any'
) {
    const asyncGetter = useCallback(() => fetchCanUseDeviceAuthPolicy(policy), [
        policy,
    ]);
    return useOnMount(asyncGetter, false);
}

export function useSupportedBiometryType() {
    return useOnMount(fetchSupportedBiometryType, 'unknown');
}

type AsyncKeychainHook = Readonly<{
    setItem: (
        account: string,
        password: string,
        options?: SaveOptions
    ) => Promise<boolean>;
    removeItem: (account: string, options?: Options) => Promise<boolean>;
    containsItem: (options?: AccountOptions) => Promise<boolean>;
    findItem: (
        options?: AccountOptions
    ) => Promise<InternetCredentials | undefined>;
    resetItems: (options?: Options) => Promise<boolean>;
    retrieveItems: (
        options?: AccountOptions
    ) => Promise<InternetCredentials[] | undefined>;
}>;

export function useKeychain(server: string): AsyncKeychainHook {
    return {
        setItem: (...args) => saveInternetPassword(server, ...args),
        removeItem: (...args) => removeInternetPassword(server, ...args),
        containsItem: (...args) => containsAnyInternetPassword(server, ...args),
        findItem: (...args) => findInternetPassword(server, ...args),
        resetItems: (...args) => resetInternetPasswords({ server, ...args }),
        retrieveItems: (...args) =>
            retrieveInternetPasswords({ server, ...args }),
    };
}

export default {
    keychainErrorCode,
};
