import { NativeModules } from 'react-native';
import { fetchSupportedBiometryType } from '..';
import { BiometryType } from '../internal/types';

describe('react-native-keychain-q#fetchSupportedBiometryType', () => {
    const biometryTypes: BiometryType[] = ['faceID', 'touchID', 'none'];
    describe.each(biometryTypes)('resolved(%s) from NativeModule', t => {
        let subject: BiometryType | 'unknown';

        beforeEach(async () => {
            jest.clearAllMocks();
            NativeModules.KeychainQ.fetchSupportedBiometryType.mockResolvedValue(
                t
            );
            subject = await fetchSupportedBiometryType();
        });
        it(`returns ${t}`, () => expect(subject).toBe(t));
    });
});
