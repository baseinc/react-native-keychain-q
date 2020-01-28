import { NativeModules } from 'react-native';
import { saveInternetPassword } from '..';

describe('react-native-keychain-q#saveInternetPassword', () => {
    describe('requested without options to NativeModule', () => {
        const params = {
            server: 'https://keychain-q.example.com',
            account: 'bob',
            password: 'pass',
        };
        describe('saved successfully and returns true from NativeModule', () => {
            beforeEach(() => {
                jest.clearAllMocks();
                NativeModules.KeychainQ.saveInternetPassword.mockResolvedValue(
                    true
                );
            });

            it('called NativeModule', async () => {
                const subject = await saveInternetPassword(
                    params.server,
                    params.account,
                    params.password
                );
                expect(subject).toBeTruthy();
                expect(
                    NativeModules.KeychainQ.saveInternetPassword
                ).toHaveBeenCalledWith(
                    params.server,
                    params.account,
                    params.password,
                    {}
                );
            });
        });
    });
});
