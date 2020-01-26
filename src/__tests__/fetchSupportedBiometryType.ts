import { NativeModules } from 'react-native';
import { fetchSupportedBiometryType } from '..';

describe('react-native-keychain-q#fetchSupportedBiometryType', () => {
    describe('NativeModule returns `none`', () => {
        beforeEach(() => {
            jest.clearAllMocks();
            NativeModules.KeychainQ.fetchSupportedBiometryType.mockResolvedValue(
                'none'
            );
        });
        it('foo', async () => {
            const result = await fetchSupportedBiometryType();
            expect(result).toBe('none');
        });
    });
});
