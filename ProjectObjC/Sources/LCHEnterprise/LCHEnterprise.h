#import <Foundation/Foundation.h>

@class LCHBuilding;
@class LCHCarWash;
@class LCHEmployee;
@class LCHCar;

@interface LCHEnterprise : NSObject
@property (nonatomic, readonly) NSSet   *buildings;
@property (nonatomic, readonly) NSSet   *employees;

+ (instancetype)enterprise;
+ (instancetype)enterpriseWithOffice:(LCHBuilding *)office carWash:(LCHCarWash *)carWash;

- (instancetype)initWithOffice:(LCHBuilding *)office carWash:(LCHCarWash *)carWash;

- (void)addBuilding:(LCHBuilding *)building;
- (void)removeBuilding:(LCHBuilding *)building;

- (void)hireAnEmployee:(LCHEmployee *)employee;
- (void)fireAnEmployee:(LCHEmployee *)employee;

- (void)performWorkWithCar:(LCHCar *)car;
- (void)performWorkWithCars:(NSSet *)cars;

@end
