import { NativeModules } from 'react-native';
import { findInternetPassword } from '..';
import { InternetCredentials } from '../internal/types';

describe('react-native-keychain-q#findInternetPassword', () => {
    describe('requested server to NativeModule', () => {
        describe('with valid server', () => {
            const servers = [
                'https://keychain-q.example.com',
                'keychain-q.example.com',
            ];
            describe.each(servers)('%s', server => {
                describe('returns undefined when item not found from NativeModule', () => {
                    beforeEach(() => {
                        jest.clearAllMocks();
                        NativeModules.KeychainQ.findInternetPassword.mockResolvedValue(
                            undefined
                        );
                    });

                    it('called NativeModule', async () => {
                        const subject = await findInternetPassword(server);
                        expect(subject).toBeUndefined();
                        expect(
                            NativeModules.KeychainQ.findInternetPassword
                        ).toHaveBeenCalledWith(server, {});
                    });
                });

                describe('returns a credentials from NativeModule', () => {
                    const resolvedValue: InternetCredentials = {
                        server: 'keychain-q.example.com',
                        account: 'bob',
                        password: 'pass',
                        createdAt: new Date(),
                        modifiedAt: new Date(),
                    };
                    beforeEach(() => {
                        jest.clearAllMocks();
                        NativeModules.KeychainQ.findInternetPassword.mockResolvedValue(
                            resolvedValue
                        );
                    });

                    it('called NativeModule', async () => {
                        const subject = await findInternetPassword(server);
                        expect(subject).toBe(resolvedValue);
                        expect(
                            NativeModules.KeychainQ.findInternetPassword
                        ).toHaveBeenCalledWith(server, {});
                    });
                });
            });
        });
    });
});
