import { DeviceOwnerAuthPolicy } from '../internal/types';
import { NativeModules } from 'react-native';
import { fetchCanUseDeviceAuthPolicy } from '..';

describe('react-native-keychain-q#fetchCanUseDeviceAuthPolicy', () => {
    describe('passed supported input auth policy', () => {
        describe('requested default value without arguments to NativeModule', () => {
            describe('returns true from NativeModule', () => {
                beforeEach(() => {
                    jest.clearAllMocks();
                    NativeModules.KeychainQ.fetchCanUseDeviceAuthPolicy.mockResolvedValue(
                        true
                    );
                });

                it('called NativeModule', async () => {
                    const subject = await fetchCanUseDeviceAuthPolicy();
                    expect(subject).toBeTruthy();
                    expect(
                        NativeModules.KeychainQ.fetchCanUseDeviceAuthPolicy
                    ).toHaveBeenCalledWith('any');
                });
            });

            describe('returns false from NativeModule such as disallowed', () => {
                beforeEach(() => {
                    jest.clearAllMocks();
                    NativeModules.KeychainQ.fetchCanUseDeviceAuthPolicy.mockResolvedValue(
                        false
                    );
                });
                it('called NativeModule', async () => {
                    const subject = await fetchCanUseDeviceAuthPolicy();
                    expect(subject).toBeFalsy();
                    expect(
                        NativeModules.KeychainQ.fetchCanUseDeviceAuthPolicy
                    ).toHaveBeenCalledWith('any');
                });
            });
        });

        const authPolicy: DeviceOwnerAuthPolicy[] = ['biometrics', 'any'];
        describe.each(authPolicy)(
            'requested(%s) to NativeModule',
            inputPolicy => {
                describe('returns true from NativeModule', () => {
                    beforeEach(() => {
                        jest.clearAllMocks();
                        NativeModules.KeychainQ.fetchCanUseDeviceAuthPolicy.mockResolvedValue(
                            true
                        );
                    });

                    it('called NativeModule', async () => {
                        const subject = await fetchCanUseDeviceAuthPolicy(
                            inputPolicy
                        );
                        expect(subject).toBeTruthy();
                        expect(
                            NativeModules.KeychainQ.fetchCanUseDeviceAuthPolicy
                        ).toHaveBeenCalledWith(inputPolicy);
                    });
                });
            }
        );

        const invalidAutoPolicy: string[] = ['none', 'dummy'];
        describe.each(invalidAutoPolicy)(
            'requested(%s) to NativeModule',
            inputPolicy => {
                describe('throws an error from NativeModule', () => {
                    let received: Error;
                    beforeEach(() => {
                        jest.clearAllMocks();
                        const error = new Error(
                            `${inputPolicy} is an invalid.`
                        );
                        Object.defineProperty(error, 'code', {
                            value: 'inputValueInvalid',
                            writable: false,
                        });
                        received = error;
                        NativeModules.KeychainQ.fetchCanUseDeviceAuthPolicy.mockRejectedValue(
                            error
                        );
                    });

                    it('fails with an error', async () => {
                        try {
                            // eslint-disable-next-line @typescript-eslint/ban-ts-ignore
                            // @ts-ignore
                            await fetchCanUseDeviceAuthPolicy(inputPolicy);
                        } catch (error) {
                            expect(error).toMatchObject(received);
                        }
                        expect(
                            NativeModules.KeychainQ.fetchCanUseDeviceAuthPolicy
                        ).toHaveBeenCalledWith(inputPolicy);
                    });
                });
            }
        );
    });
});
