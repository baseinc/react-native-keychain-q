#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(KeychainQ, NSObject)

RCT_EXTERN_METHOD(sampleMethod:(NSString *)stringArgument numberParameter:(nonnull NSNumber *)numberArgument callback:(RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(fetchSupportedBiometryType:(nonnull RCTPromiseResolveBlock)resolver rejecter:(nonnull RCTPromiseRejectBlock)rejecter)
RCT_EXTERN_METHOD(setInternetPassword:(nonnull NSString *)server account:(nonnull NSString *)account password:(nonnull NSString *)password options:(NSDictionary<NSString *, id> *)options resolver:(nonnull RCTPromiseResolveBlock)resolver rejecter:(nonnull RCTPromiseRejectBlock)rejecter)
RCT_EXTERN_METHOD(removeInternetPassword:(nonnull NSString *)server account:(nonnull NSString *)account resolver:(nonnull RCTPromiseResolveBlock)resolver rejecter:(nonnull RCTPromiseRejectBlock)rejecter)
RCT_EXTERN_METHOD(containsAnyInternetPassword:(nonnull NSString *)server options:(NSDictionary<NSString *, id> *)options resolver:(nonnull RCTPromiseResolveBlock)resolver rejecter:(nonnull RCTPromiseRejectBlock)rejecter)
RCT_EXTERN_METHOD(findInternetPassword:(nonnull NSString *)server options:(NSDictionary<NSString *, id> *)options resolver:(nonnull RCTPromiseResolveBlock)resolver rejecter:(nonnull RCTPromiseRejectBlock)rejecter)
RCT_EXTERN_METHOD(resetInternetPasswords:(NSString *)server resolver:(nonnull RCTPromiseResolveBlock)resolver rejecter:(nonnull RCTPromiseRejectBlock)rejecter)
RCT_EXTERN_METHOD(searchInternetPasswords:(NSString *)server options:(NSDictionary<NSString *, id> *)options resolver:(nonnull RCTPromiseResolveBlock)resolver rejecter:(nonnull RCTPromiseRejectBlock)rejecter)

@end
