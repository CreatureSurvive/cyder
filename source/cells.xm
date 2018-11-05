#import <cyder.h>

UIColor *LabelColor(BOOL detail, BOOL commercial, BOOL removing) {
	if (commercial) {
		return [UIColor colorWithRed:0.15f green:0.56f blue:0.84f alpha:detail ? 0.5f : 1];
	} else if (removing) {
		return [UIColor colorWithRed:0.87f green:0.31f blue:0.20f alpha:detail ? 0.5f : 1];
	}
	return [[UIColor darkTextColor] colorWithAlphaComponent:detail ? 0.5f : 1];
}

%hook PackageCell
%property (nonatomic, retain) UIImageView *icon;
%property (nonatomic, retain) UIImageView *badge;
%property (nonatomic, retain) UILabel *name;
%property (nonatomic, retain) UILabel *description;
%property (nonatomic, retain) UILabel *source;

- (void)layoutSubviews {
	%orig;
	self.backgroundColor = nil;
	self.contentView.layer.cornerRadius = 13;
	self.contentView.layer.masksToBounds = YES;
	self.contentView.frame = UIEdgeInsetsInsetRect(self.contentView.frame, UIEdgeInsetsMake(2.5, 5, 2.5, 5));
	
	CGRect bounds = self.contentView.bounds;
		
	if (self.name) {
		self.name.frame = CGRectMake(48, 10, CGRectGetWidth(bounds) - 52, 20);
	}
	
	if (self.source) {
		self.source.frame = CGRectMake(48, 30, CGRectGetWidth(bounds) - 52, 15);
	}

	if (self.description) {
		self.description.frame = CGRectMake(10, CGRectGetHeight(bounds) - 22, CGRectGetWidth(bounds) - 20, 18);
	}
}

- (void) setPackage:(Package *)package asSummary:(bool)summary {
	UIView *content = (UIView *)object_getIvar(self, class_getInstanceVariable([self class], "content_"));
	content.backgroundColor = [UIColor whiteColor];
	
	[package parse];
	
	NSString *badge;
	if (NSString *mode = [package mode]) {
		badge = ([mode isEqualToString:@"REMOVE"] || [mode isEqualToString:@"PURGE"]) ? @"removing" : @"installing";
	} else if (package.installed) {
		badge = @"installed";
	}
	
	BOOL commercial = package.isCommercial;
	BOOL removing = [badge isEqualToString:@"removing"];
	
	if (!self.icon) {
		self.icon = [[UIImageView alloc] initWithImage:package.icon];
		self.icon.frame = CGRectMake(10, 10, 30, 30);
		self.badge.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		self.icon.contentMode = UIViewContentModeScaleAspectFit;
		[self.contentView addSubview:self.icon];
	}
	
	if (!self.name) {
		self.name = [[UILabel alloc] initWithFrame:CGRectZero];
		self.name.font = [UIFont systemFontOfSize:16];
		self.name.textColor = LabelColor(NO, commercial, removing);
		self.name.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self.contentView addSubview:self.name];
	}
	
	if (!self.source) {
		self.source = [[UILabel alloc] initWithFrame:CGRectZero];
		self.source.font = [UIFont systemFontOfSize:12];
		self.source.textColor = LabelColor(NO, commercial, removing);
		self.source.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self.contentView addSubview:self.source];
	}
	
	if (!self.description) {
		self.description = [[UILabel alloc] initWithFrame:CGRectZero];
		self.description.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
		self.description.textColor = LabelColor(YES, commercial, removing);
		self.description.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self.contentView addSubview:self.description];
	}
	
	if (!self.badge) {
		self.badge = [[UIImageView alloc] initWithFrame:CGRectZero];
		self.badge.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - 26, 10, 16, 16);
		self.badge.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		self.badge.contentMode = UIViewContentModeScaleAspectFit;
		[self.contentView addSubview:self.badge];
	}
	
	self.icon.image = package.icon;
	self.name.text = package.name;
	self.source.text = [package.source rooturi];
	self.description.text = package.shortDescription;
	self.badge.image = badge ? [UIImage imageNamed:badge] : nil;
}

- (void) drawSummaryContentRect:(CGRect)rect {}
- (void) drawNormalContentRect:(CGRect)rect {}
- (void) drawContentRect:(CGRect)rect {}

%end

%hook SourceCell

- (void)layoutSubviews {
	%orig;
	self.backgroundColor = nil;
	self.contentView.layer.cornerRadius = 13;
	self.contentView.layer.masksToBounds = YES;
	self.contentView.frame = UIEdgeInsetsInsetRect(self.editing ? self.contentView.frame : self.bounds, UIEdgeInsetsMake(2.5, 5, 2.5, 5));
}

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

%hook UITableView

- (void)layoutSubviews {
	%orig;
	self.sectionIndexBackgroundColor = [UIColor clearColor];
	self.separatorColor = [UIColor clearColor];
	self.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

%end
