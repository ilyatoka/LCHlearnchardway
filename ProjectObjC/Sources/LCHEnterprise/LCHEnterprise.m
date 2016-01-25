#import "LCHEnterprise.h"
#import "LCHDispatcher.h"
#import "LCHManager.h"
#import "LCHAccountant.h"
#import "LCHWasherman.h"

static const NSUInteger kLCHDefaultWashermanCount   = 3;
static const NSUInteger kLCHDefaultAccountantCount  = 2;
static const NSUInteger kLCHDefaultManagerCount     = 1;

@interface LCHEnterprise ()
@property (nonatomic, retain)   LCHDispatcher   *washermanDispatcher;
@property (nonatomic, retain)   LCHDispatcher   *accountantDispatcher;
@property (nonatomic, retain)   LCHDispatcher   *managerDispatcher;
@property (nonatomic, retain)   NSMutableArray  *mutableEmployees;

- (void)hireEmployees;
- (void)retireEmployees;

- (void)setupEmployees:(NSArray *)employees withDispatcher:(LCHDispatcher *)dispatcher;

@end

@implementation LCHEnterprise

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)dealloc {
    [self retireEmployees];
    
    self.washermanDispatcher = nil;
    self.accountantDispatcher = nil;
    self.managerDispatcher = nil;
    
    [super dealloc];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.washermanDispatcher = [LCHDispatcher object];
        self.accountantDispatcher = [LCHDispatcher object];
        self.managerDispatcher = [LCHDispatcher object];
        
        [self hireEmployees];
    }
    
    return self;
}

#pragma mark -
#pragma mark Public

- (void)performWorkWithCar:(LCHCar *)car {
    [self.washermanDispatcher performWorkWithObject:car];
}

#pragma mark -
#pragma mark Private

- (void)hireEmployees {
    self.mutableEmployees = [NSMutableArray array];
    
    NSArray *washers = [LCHWasherman objectsWithCount:kLCHDefaultWashermanCount];
    NSArray *accountants = [LCHAccountant objectsWithCount:kLCHDefaultAccountantCount];
    NSArray *managers = [LCHManager objectsWithCount:kLCHDefaultManagerCount];
    
    [self setupEmployees:washers withDispatcher:self.washermanDispatcher];
    [self setupEmployees:accountants withDispatcher:self.accountantDispatcher];
    [self setupEmployees:managers withDispatcher:self.managerDispatcher];
}

- (void)retireEmployees {
    for (id employee in self.mutableEmployees) {
        [employee removeObserver:self];
    }
    
    self.mutableEmployees = nil;
}

- (void)setupEmployees:(NSArray *)employees withDispatcher:(LCHDispatcher *)dispatcher {
    NSMutableArray *mutableEmployees = self.mutableEmployees;
    
    for (id employee in employees) {
        [dispatcher addHandler:employee];
        [mutableEmployees addObject:employee];
        [employee addObserver:self];
    }
}

#pragma mark -
#pragma mark LCHObserverProtocol

- (void)employeeDidFinishWork:(id)employee {
    if ([self.washermanDispatcher containsHandler:employee]) {
        [self.accountantDispatcher performWorkWithObject:employee];
    } else if ([self.accountantDispatcher containsHandler:employee]) {
        [self.managerDispatcher performWorkWithObject:employee];
    }
}

@end
