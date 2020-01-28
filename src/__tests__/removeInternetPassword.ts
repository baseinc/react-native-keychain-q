import { NativeModules } from 'react-native';
import { removeInternetPassword } from '..';

describe('react-native-keychain-q#removeInternetPassword', () => {
    describe('requested without options to NativeModule', () => {
        const params = {
            server: 'https://keychain-q.example.com',
            account: 'bob',
        };
        describe('removed successfully and returns true from NativeModule', () => {
            beforeEach(() => {
                jest.clearAllMocks();
                NativeModules.KeychainQ.removeInternetPassword.mockResolvedValue(
                    true
                );
            });

            it('called NativeModule', async () => {
                const subject = await removeInternetPassword(
                    params.server,
                    params.account
                );
                expect(subject).toBeTruthy();
                expect(
                    NativeModules.KeychainQ.removeInternetPassword
                ).toHaveBeenCalledWith(params.server, params.account, {});
            });
        });
    });
});
