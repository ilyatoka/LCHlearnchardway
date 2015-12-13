#import "LCHEnterprise.h"
#import "LCHBuilding.h"
#import "LCHCarWash.h"
#import "LCHRoom.h"
#import "LCHWashBox.h"
#import "LCHEmployee.h"
#import "LCHManager.h"
#import "LCHAccountant.h"
#import "LCHWasherman.h"
#import "LCHCar.h"

static const NSUInteger kLCHDefaultPrice = 5;

@interface LCHEnterprise ()
@property (nonatomic, readwrite, retain) NSMutableSet *mutableBuildings;
@property (nonatomic, readwrite, retain) NSMutableSet *mutableEmployees;

- (id)emptyRoomForEmployee:(id)employee;
- (id)roomWithEmployee:(id)employee;

- (void)updateMoneyReceivers;

@end

@implementation LCHEnterprise
@dynamic buildings;
@dynamic employees;

#pragma mark -
#pragma Class Methods
+ (instancetype)enterprise {
    return [[self alloc ] initWithOffice:[LCHBuilding building] carWash:[LCHCarWash building]];
}

+ (instancetype)enterpriseWithOffice:(LCHBuilding *)office carWash:(LCHCarWash *)carWash {
    return [[self alloc ] initWithOffice:office carWash:carWash];
}

#pragma mark -
#pragma mark Initializations and Deallocations

- (void)dealloc {
    self.mutableBuildings = nil;
    self.mutableEmployees = nil;
    
    [super dealloc];
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.mutableBuildings = [NSMutableSet set];
        self.mutableEmployees = [NSMutableSet set];
    }
    
    return self;
}

- (instancetype)initWithOffice:(LCHBuilding *)office carWash:(LCHCarWash *)carWash {
    self = [self init];
    
    if (self) {
        [self.mutableBuildings addObject:office];
        [self.mutableBuildings addObject:carWash];
    }
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (NSSet *)buildings {
    return [[self.mutableBuildings copy] autorelease];
}

- (NSSet *)employees {
    return [[self.mutableEmployees copy] autorelease];
}

#pragma mark -
#pragma mark Public Implementations

- (void)addBuilding:(LCHBuilding *)building {
    [self.mutableBuildings addObject:building];
}

- (void)removeBuilding:(LCHBuilding *)building {
    for (id room in building.rooms) {
        [building removeRoom:room];
    }
    
    [self.mutableBuildings removeObject:building];
}

- (void)hireAnEmployee:(LCHEmployee *)employee {
    id room = [self emptyRoomForEmployee:employee];
    
    if (room) {
        [room addEmployee:employee];
        [employee __addParrentRoom:room];
        
        [self.mutableEmployees addObject:employee];
        [self updateMoneyReceivers];
    }
}

- (void)fireAnEmployee:(LCHEmployee *)employee {
    [[self roomWithEmployee:employee] removeEmployee:employee];
    [employee __removeParrentRoom];
    
    [self.mutableEmployees removeObject:employee];
    [self updateMoneyReceivers];
}

- (void)performWorkWithCar:(LCHCar *)car {
    LCHWashBox *washBox = nil;
    LCHWasherman *washerman = nil;
    
    for (id building in self.mutableBuildings) {
        for (id room in [building rooms]) {
            if ([room respondsToSelector:@selector(isAbleToContainCars)] && ![room isFullOfCars]) {
                washBox = room;
            }
        }
    }
    
    for (id employee in self.employees) {
        if ([employee respondsToSelector:@selector(isAbleToWash)]) {
            washerman = employee;
        }
    }
    
    if ([car canGiveMoney:kLCHDefaultPrice]) {
        if (washBox && washerman) {
            [washBox addCar:car];
            [car addMoneyReceiver:washerman];
            [washerman performEmployeeSpecificOperationWithPrise:kLCHDefaultPrice];
            [washBox removeCar:car];
            [washerman.receiver performEmployeeSpecificOperationWithPrise:kLCHDefaultPrice];
        }
    }
}

- (void)performWorkWithCars:(NSSet *)cars {
    for (LCHCar *car in cars) {
        [self performWorkWithCar:car];
    }
}

#pragma mark -
#pragma mark Private Implementations

- (id)emptyRoomForEmployee:(id)employee {
    BOOL isWasherman = [employee respondsToSelector:@selector(isAbleToWash)];
    id emptyRoom = nil;
    
    for (id building in self.mutableBuildings) {
        for (id room in [building rooms]) {
            if (![room isFull]) {
                if (isWasherman) {
                    if ([room respondsToSelector:@selector(isAbleToContainCars)]) {
                        emptyRoom = room;
                        
                        break;
                    }
                } else {
                    if (![room respondsToSelector:@selector(isAbleToContainCars)]) {
                        emptyRoom = room;
                        
                        break;
                    }
                }
            }
        }
    }

    return emptyRoom;
}

- (id)roomWithEmployee:(id)employee {
    id emptyRoom = nil;
    
    for (id building in self.mutableBuildings) {
        for (id room in [building rooms]) {
            for (id currentEmployee in [room employees]) {
                if (currentEmployee == employee) {
                    emptyRoom = room;
                    
                    break;
                }
            }
        }
    }
    
    return emptyRoom;
}

- (void)updateMoneyReceivers {
    NSSet *employees = self.employees;
    NSMutableSet *washermans = [NSMutableSet set];
    LCHAccountant *accountant = nil;
    LCHManager *manager = nil;
    
    for (id employee in employees) {
        if ([employee isKindOfClass:[LCHWasherman class]]) {
            [washermans addObject:employee];
        } else if ([employee isKindOfClass:[LCHAccountant class]]) {
            accountant = employee;
        } else if ([employee isKindOfClass:[LCHManager class]]) {
            manager = employee;
        }
    }
    
    for (LCHWasherman *washerman in washermans) {
        if (accountant) {
            [washerman addMoneyReceiver:accountant];
        } else {
            [washerman removeMoneyReceiver];
        }
    }
    
    if (manager) {
        [accountant addMoneyReceiver:manager];
    } else {
        [accountant removeMoneyReceiver];
    }
}

@end
