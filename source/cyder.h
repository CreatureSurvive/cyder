#include "CYPProvider.h"
#define COMPATIBILITY_PATH  @"/var/mobile/Library/Caches/com.saurik.Cydia/cyder-compatibility.plist"

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
@property (nonatomic, retain) NSDictionary *cyderCompatibilityList;
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
@property (nonatomic, retain) NSDictionary *cyderCompatibility;
- (void)syncData;
- (BOOL)addTrivialSource:(NSString *)href;
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
- (void)parse;
- (char)ignored;
- (BOOL)setSubscribed:(BOOL)subscribed;
- (BOOL)subscribed;
- (BOOL)isCommercial;
- (UIImage *)icon;
- (NSString *)id;
- (NSString *)name;
- (NSString *)mode;
- (NSString *)latest;
- (NSString *)longDescription;
- (NSString *)shortDescription;
- (NSString *)installed;
- (Source *)source;
@end

@interface PackageCell : UITableViewCell
@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UIImageView *badge;
@property (nonatomic, retain) UIView *compatible_badge;
@property (nonatomic, retain) UILabel *name;
@property (nonatomic, retain) UILabel *description;
@property (nonatomic, retain) UILabel *source;
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
- (void)addViewControllers:(id)no, ...;
@end

@protocol CyteTableViewCellDelegate
- (void)drawContentRect:(CGRect)rect;
@end

@interface CyteTableViewCellContentView : UIView

- (id)delegate;
- (void)setDelegate:(id<CyteTableViewCellDelegate>)delegate;

@end

@interface CyteTableViewCell : UITableViewCell

- (void)setContent:(CyteTableViewCellContentView *)content;
- (CyteTableViewCellContentView *) content;

- (bool)highlighted;

@end
