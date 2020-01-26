/**
 * @default whenUnlocked
 */
export type Accessible =
    | 'whenPasscodeSetThisDeviceOnly'
    | 'whenUnlockedThisDeviceOnly'
    | 'whenUnlocked'
    | 'afterFirstUnlockThisDeviceOnly'
    | 'afterFirstUnlock';

export type AccessControlConstraints =
    | 'devicePasscode'
    | 'biometryAny'
    | 'biometryCurrentSet'
    | 'userPresence'
    | 'applicationPassword';

export type BiometryType = 'touchID' | 'faceID' | 'none';
export type BiometryTypeLabel = Readonly<{ label: string | undefined }>;
export const biometryTypeLabel: Readonly<Record<
    BiometryType,
    BiometryTypeLabel
>> = {
    touchID: { label: 'Touch ID' },
    faceID: { label: 'Face ID' },
    none: { label: undefined },
};

export type DeviceOwnerAuthPolicy = 'biometrics' | 'any' | 'none';

export type Credentials<T> = Readonly<
    {
        [P in keyof T]: T[P];
    } & {
        account: string;
        password: string;
        createdAt: Date;
        modifiedAt: Date;
    }
>;

export type InternetCredentials = Credentials<{
    server: string;
    port?: number;
}>;

export type Options<T extends {} = {}> = {
    [P in keyof T]: T[P];
} & {
    accessGroup?: string;
    authenticationPrompt?: string;
    deviceOwnerAuthPolicy?: DeviceOwnerAuthPolicy;
};

export type SaveOptions = Options<{
    accessible?: Accessible;
    accessControls?: AccessControlConstraints[];
}>;

export type ServerOptions = Options<
    Partial<{
        server: string;
    }>
>;

export type AccountOptions = Options<
    Partial<{
        account: string;
    }>
>;

export type ServerAccountOptions = Options<
    Partial<{
        server: string;
        account: string;
    }>
>;

export type KeychainErrorCodes =
    | 'userCanceled'
    | 'noPassword'
    | 'notAvailable'
    | 'inputPasswordInvalid'
    | 'inputValueInvalid'
    | 'unexpectedPasswordData'
    | 'unhandledException';

/**
 * @see https://github.com/react-native-community/react-native-device-info
 */
export interface AsyncHookResult<T> {
    loading: boolean;
    result: T;
}
