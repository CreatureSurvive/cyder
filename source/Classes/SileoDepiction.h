#import <UIKit/UIKit.h>
typedef NSDictionary<NSString *, NSString *> *DataSourceEntry;
typedef NSArray<DataSourceEntry> *DataSource;
typedef NSDictionary<NSString *, id> *RootDataSource;

@interface SileoDepiction : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RootDataSource data;
@property (nonatomic, assign) UITableViewCellStyle cellStyle;

+ (instancetype)rootViewControllerWithPlist:(NSString *)plist;
+ (instancetype)rootViewControllerWithData:(RootDataSource)data;
+ (instancetype)rootViewControllerWithData:(RootDataSource)data cellStyle:(UITableViewCellStyle)style;

@end