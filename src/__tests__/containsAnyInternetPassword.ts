import { NativeModules } from 'react-native';
import { containsAnyInternetPassword } from '..';

describe('react-native-keychain-q#containsAnyInternetPassword', () => {
    describe('requested without options to NativeModule', () => {
        describe('with valid server', () => {
            const servers = [
                'https://keychain-q.example.com',
                'keychain-q.example.com',
            ];
            describe.each(servers)('%s', server => {
                describe('returns true from NativeModule', () => {
                    beforeEach(() => {
                        jest.clearAllMocks();
                        NativeModules.KeychainQ.containsAnyInternetPassword.mockResolvedValue(
                            true
                        );
                    });

                    it('called NativeModule', async () => {
                        const subject = await containsAnyInternetPassword(
                            server
                        );
                        expect(subject).toBeTruthy();
                        expect(
                            NativeModules.KeychainQ.containsAnyInternetPassword
                        ).toHaveBeenCalledWith(server, {});
                    });
                });

                describe('returns false from NativeModule', () => {
                    beforeEach(() => {
                        jest.clearAllMocks();
                        NativeModules.KeychainQ.containsAnyInternetPassword.mockResolvedValue(
                            false
                        );
                    });

                    it('called NativeModule', async () => {
                        const subject = await containsAnyInternetPassword(
                            server
                        );
                        expect(subject).toBeFalsy();
                        expect(
                            NativeModules.KeychainQ.containsAnyInternetPassword
                        ).toHaveBeenCalledWith(server, {});
                    });
                });
            });
        });

        describe('with invalid server', () => {
            const servers = ['/path/to/a.js'];
            describe.each(servers)('%s', server => {
                describe('throws an exception from NativeModule', () => {
                    let received: Error;
                    beforeEach(() => {
                        jest.clearAllMocks();
                        const error = new Error(`${server} is an invalid.`);
                        Object.defineProperty(error, 'code', {
                            value: 'inputValueInvalid',
                            writable: false,
                        });
                        received = error;
                        NativeModules.KeychainQ.containsAnyInternetPassword.mockRejectedValue(
                            error
                        );
                    });

                    it('fails with an error', async () => {
                        try {
                            await containsAnyInternetPassword(server);
                        } catch (error) {
                            expect(error).toMatchObject(received);
                        }
                    });
                });
            });
        });
    });
});
