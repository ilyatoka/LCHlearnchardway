#import <Foundation/Foundation.h>
#import "LCHObserverProtocol.h"

@interface LCHController : NSObject <LCHObserverProtocol>

+ (instancetype)controllerWithEnterprise:(id)enterprise;

- (instancetype)initWithEnterprise:(id)enterprise;

- (void)performWorkWithObject:(id)object;
- (void)performWorkWithObjects:(NSArray *)objects;

@end
