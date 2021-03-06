#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(KeychainQ, NSObject)

RCT_EXTERN_METHOD(fetchCanUseDeviceAuthPolicy:(nonnull NSString *)rawValue resolver:(nonnull RCTPromiseResolveBlock)resolver rejecter:(nonnull RCTPromiseRejectBlock)rejecter)
RCT_EXTERN_METHOD(fetchSupportedBiometryType:(nonnull RCTPromiseResolveBlock)resolver rejecter:(nonnull RCTPromiseRejectBlock)rejecter)
RCT_EXTERN_METHOD(saveInternetPassword:(nonnull NSString *)server account:(nonnull NSString *)account password:(nonnull NSString *)password options:(NSDictionary<NSString *, id> *)options resolver:(nonnull RCTPromiseResolveBlock)resolver rejecter:(nonnull RCTPromiseRejectBlock)rejecter)
RCT_EXTERN_METHOD(removeInternetPassword:(nonnull NSString *)server account:(nonnull NSString *)account options:(NSDictionary<NSString *, id> *)options resolver:(nonnull RCTPromiseResolveBlock)resolver rejecter:(nonnull RCTPromiseRejectBlock)rejecter)
RCT_EXTERN_METHOD(containsAnyInternetPassword:(nonnull NSString *)server options:(NSDictionary<NSString *, id> *)options resolver:(nonnull RCTPromiseResolveBlock)resolver rejecter:(nonnull RCTPromiseRejectBlock)rejecter)
RCT_EXTERN_METHOD(findInternetPassword:(nonnull NSString *)server options:(NSDictionary<NSString *, id> *)options resolver:(nonnull RCTPromiseResolveBlock)resolver rejecter:(nonnull RCTPromiseRejectBlock)rejecter)
RCT_EXTERN_METHOD(resetInternetPasswords:(NSString *)server options:(NSDictionary<NSString *, id> *)options resolver:(nonnull RCTPromiseResolveBlock)resolver rejecter:(nonnull RCTPromiseRejectBlock)rejecter)
RCT_EXTERN_METHOD(retrieveInternetPasswords:(NSString *)server options:(NSDictionary<NSString *, id> *)options resolver:(nonnull RCTPromiseResolveBlock)resolver rejecter:(nonnull RCTPromiseRejectBlock)rejecter)

@end
