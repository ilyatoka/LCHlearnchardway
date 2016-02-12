#import "PUShopListViewController.h"

#import "PUShopListItems.h"
#import "PUShopListItem.h"

#import "PUShopListView.h"
#import "PUShopListCell.h"

#import "NSString+PURandomFoodName.h"

#import "PUViewControllerMacro.h"

PUViewControllerBaseViewProperty(PUShopListViewController, baseView, PUShopListView)

@implementation PUShopListViewController

#pragma mark -
#pragma mark Accessors

- (void)setShopListItems:(PUShopListItems *)shopListItems {
    if (_shopListItems != shopListItems) {
        [_shopListItems removeObserver:self];
        _shopListItems = shopListItems;
        [_shopListItems addObserver:self];
        
        [self.baseView.tableView reloadData];
    }
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.baseView.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Public

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)onAddItem:(id)sender {
    [self.shopListItems insertObject:[PUShopListItem shopListItemWithName:[NSString randomName]] atIndex:0];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.shopListItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [PUShopListCell class];
    NSString *cellClassString = NSStringFromClass(cellClass);
    
    PUShopListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellClassString];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:cellClassString bundle:nil];
        NSArray *cells = [nib instantiateWithOwner:nil options:nil];
        
        for (id result in cells) {
            if ([result isMemberOfClass:cellClass]) {
                cell = result;
                
                break;
            }
        }
    }

    cell.shopListItem = self.shopListItems[indexPath.row];
    cell.layoutMargins = UIEdgeInsetsZero;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PUShopListItem *shopListItem = self.shopListItems[indexPath.row];
    shopListItem.checked = !shopListItem.checked;
}

#pragma mark -
#pragma mark PUArrayModelObserverProtocol

- (void)arrayModelDidChange:(id)model {
    NSLog(@"Item added");
}

@end
