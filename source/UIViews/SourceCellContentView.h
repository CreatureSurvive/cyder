@class Source;
@interface SourceCellContentView : UIView

@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UILabel *name;
@property (nonatomic, retain) UILabel *uri;

- (instancetype)initWithSource:(Source *)source;
- (void)refreshWithSource:(Source *)source;

@end