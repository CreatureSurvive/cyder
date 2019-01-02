#import <cyder.h>
#import <UIViews/PackageCellContentView.h>
#import <UIViews/SourceCellContentView.h>

@interface PackageCell (Cyder)
@property (nonatomic, retain) PackageCellContentView *content_view;
@end

%hook PackageCell
%property (nonatomic, retain) PackageCellContentView *content_view;

- (id)init {
	if ((self = %orig)) {
		self.content_view = [[PackageCellContentView alloc] init];
		[self.contentView addSubview:self.content_view];
	} return self;
}

- (void)layoutSubviews {
	%orig;
	self.backgroundColor = nil;
	self.contentView.layer.cornerRadius = 13;
	self.contentView.layer.masksToBounds = YES;
	self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame, UIEdgeInsetsMake(2.5, 5, 2.5, 5));
	
	self.content_view.frame = self.contentView.bounds;
}

- (void)setPackage:(Package *)package asSummary:(bool)summary {
	UIView *content = (UIView *)object_getIvar(self, class_getInstanceVariable([self class], "content_"));
	content.backgroundColor = [prefs colorForKey:@"cellColor"];//[UIColor whiteColor];
	
	[self.content_view refreshWithPackage:package asSummary:summary];
}

- (void)drawSummaryContentRect:(CGRect)rect {}
- (void)drawNormalContentRect:(CGRect)rect {}
- (void)drawContentRect:(CGRect)rect {}

%end

@interface SourceCell (Cyder)
@property (nonatomic, retain) SourceCellContentView *content_view;
@end

%hook SourceCell
%property (nonatomic, retain) SourceCellContentView *content_view;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = %orig)) {
		self.content_view = [[SourceCellContentView alloc] init];
		[self.contentView addSubview:self.content_view];
	} return self;
}

- (void)layoutSubviews {
	%orig;
	self.backgroundColor = nil;
	self.contentView.layer.cornerRadius = 13;
	self.contentView.layer.masksToBounds = YES;
	self.contentView.frame = UIEdgeInsetsInsetRect(self.editing ? self.contentView.frame : self.bounds, UIEdgeInsetsMake(2.5, 5, 2.5, 5));
	
	self.content_view.frame = self.contentView.bounds;
}

- (void)setSource:(Source *)source {
	
	UIView *content = (UIView *)object_getIvar(self, class_getInstanceVariable([self class], "content_"));
	content.backgroundColor = [prefs colorForKey:@"cellColor"];
	
	[self.content_view refreshWithSource:source];
}

- (void)setAllSource {
	[self.content_view refreshWithSource:nil];
}

- (void)drawContentRect:(CGRect)rect {}

%end

%hook SectionCell

- (void)layoutSubviews {
	%orig;
	self.backgroundColor = nil;
	self.contentView.layer.cornerRadius = 13;
	self.contentView.layer.masksToBounds = YES;
	self.contentView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(2.5, 5, 2.5, 5));
}

%end