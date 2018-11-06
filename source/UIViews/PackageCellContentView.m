#import <cyder.h>
#import "PackageCellContentView.h"

UIColor *LabelColor(BOOL detail, BOOL commercial, BOOL removing) {
	if (commercial) {
		return [[prefs colorForKey:@"commercialColor"] colorWithAlphaComponent:detail ? 0.5f : 1];//[UIColor colorWithRed:0 green:0.48f blue:1 alpha:detail ? 0.5f : 1];
	} else if (removing) {
		return [[prefs colorForKey:@"removeColor"] colorWithAlphaComponent:detail ? 0.5f : 1];//[UIColor colorWithRed:0.87f green:0.09f blue:0.09f alpha:detail ? 0.5f : 1];
	}
	return [[prefs colorForKey:@"textColor"] colorWithAlphaComponent:detail ? 0.5f : 1];//[[UIColor darkTextColor] colorWithAlphaComponent:detail ? 0.5f : 1];
}

UIColor *CompatibilityColor(NSUInteger status) {
	switch (status) {
		case 1:
			return [UIColor colorWithRed:0.3f green:0.85f blue:0.40f alpha:1];
		case 2:
			return [UIColor colorWithRed:1 green:0.18f blue:0.33f alpha:1];
		default:
			return [UIColor colorWithRed:1 green:0.8f blue:0 alpha:1];
	}
}

UIColor *InstallationColor(NSString *status, NSString **label) {
	if (!status) {
		return [UIColor lightGrayColor];
	}
	else if ([status isEqualToString:@"installed"]) {
		*label = @"✓";
		return [UIColor colorWithRed:0.3f green:0.85f blue:0.40f alpha:1];
	}
	else if ([status isEqualToString:@"installing"]) {
		*label = @"+";
		return [UIColor colorWithRed:0 green:0.48f blue:1 alpha:1];
	}
	else if ([status isEqualToString:@"removing"]) {
		*label = @"✕";
		return [UIColor colorWithRed:1 green:0.18f blue:0.33f alpha:1];
	}
	
	return [UIColor lightGrayColor];
}


@implementation PackageCellContentView

- (instancetype)init {
	if ((self = [super init])) {
		[self commonInit];
	} return self;
}

- (instancetype)initWithPackage:(Package *)package {
	if ((self = [super init])) {
		[self commonInit];
		[self refreshWithPackage:package];
	} return self;
}

- (void)commonInit {
	self.c_badge = [[UILabel alloc] init];
	self.c_badge.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
	self.c_badge.textAlignment = NSTextAlignmentCenter;
	self.c_badge.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
	self.c_badge.textColor = [UIColor darkTextColor];
	[self addSubview:self.c_badge];

	self.i_badge = [[UILabel alloc] init];
	self.i_badge.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
	self.i_badge.textAlignment = NSTextAlignmentCenter;
	self.i_badge.font = [UIFont systemFontOfSize:16 weight:UIFontWeightLight];
	self.i_badge.textColor = [UIColor darkTextColor];
	[self addSubview:self.i_badge];

	self.icon = [[UIImageView alloc] init];
	self.icon.frame = CGRectMake(10, 10, 30, 30);
	self.icon.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
	self.icon.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:self.icon];

	self.name = [[UILabel alloc] init];
	self.name.font = [UIFont systemFontOfSize:16];
	self.name.textColor = [UIColor darkTextColor];
	self.name.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self addSubview:self.name];

	self.source = [[UILabel alloc] init];
	self.source.font = [UIFont systemFontOfSize:12];
	self.source.textColor = [UIColor darkTextColor];
	self.source.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self addSubview:self.source];

	self.overview = [[UILabel alloc] init];
	self.overview.font = [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
	self.overview.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:0.5f];
	self.overview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self addSubview:self.overview];

	self.badge = [[UIImageView alloc] init];
	self.badge.frame = CGRectMake(CGRectGetWidth(self.frame) - 26, 10, 16, 16);
	self.badge.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	self.badge.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:self.badge];
	
	UIView *delemeter = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 16, CGRectGetMidY(self.frame) - 0.75f, 16, 1.5)];
	delemeter.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	delemeter.backgroundColor = [UIColor whiteColor];
	[self addSubview:delemeter];
}

- (void)refreshWithPackage:(Package *)package {
	[package parse];
	NSString *badge, *mode, *latest, *install_label;
	NSUInteger compatible = 0;
	NSDictionary *bundle;
	Database *database = [NSClassFromString(@"Database") sharedInstance];
	
	if ((mode = [package mode])) {
		badge = ([mode isEqualToString:@"REMOVE"] || [mode isEqualToString:@"PURGE"]) ? @"removing" : @"installing";
	} else if (package.installed) {
		badge = @"installed";
	}
	
	if ((bundle = database.cyderCompatibilityList[package.id])) {
		if ((latest = bundle[package.latest])) {
			compatible = [latest isEqualToString:@"Working"] ? 1 : 2;
		}
	}

	BOOL commercial = package.isCommercial;
	BOOL removing = [badge isEqualToString:@"removing"];
	
	self.name.textColor = LabelColor(NO, commercial, removing);
	self.source.textColor = LabelColor(NO, commercial, removing);
	self.overview.textColor = LabelColor(YES, commercial, removing);
	
	self.icon.image = package.icon;
	self.name.text = package.name;
	self.source.text = [package.source rooturi];
	self.overview.text = package.shortDescription;
// 	self.badge.image = badge ? [UIImage imageNamed:badge] : nil;
	self.c_badge.backgroundColor = CompatibilityColor(compatible);
	self.c_badge.text = compatible == 0 ? @"?" : compatible == 1 ? @"✓" : @"✕";
	self.i_badge.backgroundColor = InstallationColor(badge, &install_label);
	self.i_badge.text = install_label;
	
	[self setNeedsLayout];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGRect bounds = self.bounds;
		
	self.name.frame = CGRectMake(48, 10, CGRectGetWidth(bounds) - 64, 20);
	self.source.frame = CGRectMake(48, 30, CGRectGetWidth(bounds) - 64, 15);
	self.overview.frame = CGRectMake(10, CGRectGetHeight(bounds) - 22, CGRectGetWidth(bounds) - 26, 18);
	self.c_badge.frame = CGRectMake(CGRectGetWidth(bounds) - 16, CGRectGetMidY(bounds), 16, CGRectGetMidY(bounds));
	self.i_badge.frame = CGRectMake(CGRectGetWidth(bounds) - 16, 0, 16, CGRectGetMidY(bounds));
}

@end