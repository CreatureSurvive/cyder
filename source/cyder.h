#include "CYPProvider.h"
#include <CSColorPicker/CSColorPicker.h>
#include "UIImage+ScaledImage.h"

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

@interface UINavigationBar (Cyder)
-(void)setLargeTitleTextAttributes:(NSDictionary *)arg1;
@end

@interface UIStatusBar : UIView
@property (nonatomic, retain) UIColor *foregroundColor;
@end

@interface UIStatusBarBackgroundView : UIView
@end

@interface _UIStatusBar : UIView
@property (nonatomic, retain) UIColor *foregroundColor;
@end

@interface _UIBarBackground : UIView
@property (nonatomic,readonly) UIImageView * shim_shadowView; 
@end 

//Resize Image Interface and Implementation
@interface UIImage (ResizeImage)
- (UIImage *)imageScaledToSize:(CGSize)newSize;
@end
//Implementation
@implementation UIImage (ResizeImage)

- (UIImage *)imageScaledToSize:(CGSize)newSize {
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
}

@end

