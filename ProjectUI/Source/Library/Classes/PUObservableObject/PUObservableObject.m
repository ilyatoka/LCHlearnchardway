#import "PUObservableObject.h"

#import "PUClangMacro.h"

@interface PUObservableObject ()
@property (nonatomic, strong)   NSHashTable *observersHashTable;

@property (nonatomic, assign, getter=isNotificationEnabled) BOOL    notificationEnabled;

- (void)performBlock:(void(^)(void))block notify:(BOOL)shouldNotify;

@end

@implementation PUObservableObject

@dynamic observers;

#pragma mark -
#pragma mark Initializations and Deallocations

- (instancetype)init {
    self = [super init];
    if (self) {
        self.observersHashTable = [NSHashTable weakObjectsHashTable];
        self.notificationEnabled = YES;
    }
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (NSArray *)observers {
    NSHashTable *observersHashTable = self.observersHashTable;
    @synchronized(observersHashTable) {
        return [observersHashTable allObjects];
    }
    
    return nil;
}

- (void)setState:(NSUInteger)state {
    [self setState:state withObject:nil];
}

- (void)setState:(NSUInteger)state withObject:(id)object {
    @synchronized(self) {
        if (_state != state) {
            _state = state;
            [self notifyWithSelector:[self selectorForState:state] withObject:object];
        }
    }
}

#pragma mark -
#pragma mark Public

- (void)addObserver:(id)observer {
    NSHashTable *observersHashTable = self.observersHashTable;
    @synchronized(observersHashTable) {
        if (![observersHashTable containsObject:observer]) {
            [observersHashTable addObject:observer];
        }
    }
}

- (void)removeObserver:(id)observer {
    NSHashTable *observersHashTable = self.observersHashTable;
    @synchronized(observersHashTable) {
        [observersHashTable removeObject:observer];
    }
}

- (void)addObserversFromArray:(NSArray *)array {
    for (id observer in array) {
        [self addObserver:observer];
    }
}

- (void)removeObserversFromArray:(NSArray *)array {
    for (id observer in array) {
        [self removeObserver:observer];
    }
}

- (BOOL)containsObserver:(id)observer {
    NSHashTable *observersHashTable = self.observersHashTable;
    @synchronized(observersHashTable) {
        return [observersHashTable containsObject:observer];
    }
}

- (void)notifyWithSelector:(SEL)selector {
    [self notifyWithSelector:selector withObject:nil];
}

- (void)notifyWithSelector:(SEL)selector withObject:(id)object {
    @synchronized(self) {
        if (!self.notificationEnabled) {
            return;
        }

        for (id observer in self.observers) {
            if ([observer respondsToSelector:selector]) {
                PUClangDiagnosticPushExpressionPerformSelectorLeakWarning
                [observer performSelector:selector withObject:self withObject:object];
                PUClangDiagnosticPopExpression
            }
        }
    }
}

- (void)performWithNotification:(void(^)(void))block {
    [self performBlock:block notify:YES];
}

- (void)performWithoutNotification:(void(^)(void))block {
    [self performBlock:block notify:NO];
}

- (SEL)selectorForState:(NSUInteger)state {
    return NULL;
}

#pragma mark -
#pragma mark Private

- (void)performBlock:(void(^)(void))block notify:(BOOL)shouldNotify {
    @synchronized(self) {
        BOOL notificationEnabled = self.notificationEnabled;
        self.notificationEnabled = shouldNotify;
        if (block) {
            block();
        }
        
        self.notificationEnabled = notificationEnabled;
    }
}

@end
