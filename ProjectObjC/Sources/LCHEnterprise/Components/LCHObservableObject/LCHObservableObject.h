#import <Foundation/Foundation.h>
#import "LCHEmployeeObserverProtocol.h"

@interface LCHObservable : NSObject <LCHEmployeeObserverProtocol>
@property (nonatomic, readonly) NSArray     *observers;
@property (nonatomic)           NSUInteger  state;

- (void)addObserver:(id)observer;
- (void)removeObserver:(id)observer;

- (BOOL)containsObserver:(id)observer;

- (void)notifyWithSelector:(SEL)selector;
- (void)notifyWithSelector:(SEL)selector withObject:(id)object;

- (SEL)selectorForState:(NSUInteger)state;

@end
