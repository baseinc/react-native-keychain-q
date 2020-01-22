#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(KeychainQ, NSObject)

RCT_EXTERN_METHOD(sampleMethod:(NSString *)stringArgument numberParameter:(nonnull NSNumber *)numberArgument callback:(RCTResponseSenderBlock)callback)

@end
