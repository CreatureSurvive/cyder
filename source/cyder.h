@interface UIApplication ()
- (void)presentModalViewController:(id)controller force:(BOOL)force;
- (BOOL)openCydiaURL:(id)url forExternal:(BOOL)external;
- (UIViewController *)pageForPackage:(NSString *)name withReferrer:(NSString *)referrer;
- (UIViewController *)pageForURL:(NSURL *)url forExternal:(BOOL)external withReferrer:(NSString *)referrer;
@end

@interface Source : NSObject
- (NSString *)rooturi;
@end

@interface Database : NSObject
+ (Database *)sharedInstance;
- (NSArray<Source *> *)sources;
- (NSArray *)packages;
@end

@interface CydiaObject : NSObject
- (id)getPackageById:(id)identifier;
- (NSString *)version;
- (NSArray *)getInstalledPackages;
- (NSArray *)getAllSources;
@end

@interface Cydia
- (void) syncData;
- (BOOL) addTrivialSource:(NSString *)href;
- (BOOL)updating;
@end

@interface UISwipeActionButton : UIButton
@end

@interface UISwipeActionStandardButton : UISwipeActionButton
@end

@interface UISwipeActionPullView : UIView
@property (assign, nonatomic) UIEdgeInsets contentInsets;
- (id)initWithCellEdge:(NSUInteger)edge style:(NSUInteger)style;
@end

@interface Package : NSObject {
    unsigned ignored_ : 1;
}
- (char)ignored;
- (BOOL)setSubscribed:(BOOL)subscribed;
- (BOOL)subscribed;
- (NSString *)id;
- (NSString *)name;
@end

@interface PackageCell : UITableViewCell
- (void)setPackage:(Package *)package asSummary:(BOOL)summary;
@end

@interface SourceCell : UITableViewCell
@end

@interface SectionCell : UITableViewCell
@end

@interface CydiaLoadingViewController : UIViewController
@end

@interface CyteViewController : UIViewController
- (Cydia *)delegate;
@end

@interface CYPackageController : UIViewController
- (void)updatedButton;
@end

@interface CyteWebViewController : CyteViewController
- (void)reloadButtonClicked;
@end

@interface HomeController : CyteWebViewController
@end

@interface UITableViewCellSelectedBackground : UIView
@end

@interface PackageListController : CyteViewController
-(Package *)packageAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface SearchController : PackageListController
@end

@interface SourcesController : CyteViewController
@property(nonatomic, retain) UIRefreshControl *refreshControl;
- (void)setNavItemButtons;
@end

@interface ChangesController : PackageListController
@property(nonatomic, retain) UIRefreshControl *refreshControl;
- (void)refreshButtonClicked;
@end

@interface CyteTabBarController : UITabBarController
- (void) addViewControllers:(id)no, ...;
@end
