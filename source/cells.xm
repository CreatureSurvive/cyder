#import <cyder.h>


UIColor *LabelColor(BOOL detail, BOOL commercial, BOOL removing) {
	if (commercial) {
		return [prefs colorForKey:@"commercialColor"];//[UIColor colorWithRed:0.15f green:0.56f blue:0.84f alpha:detail ? 0.5f : 1];
	} else if (removing) {
		return [prefs colorForKey:@"removeColor"];//[UIColor colorWithRed:0.87f green:0.31f blue:0.20f alpha:detail ? 0.5f : 1];
	}
	return [prefs colorForKey:@"textColor"];//[[UIColor darkTextColor] colorWithAlphaComponent:detail ? 0.5f : 1];
}

UIColor *CompatibilityColor(NSUInteger status) {
	switch (status) {
		case 1:
			return [UIColor colorWithRed:0.3f green:0.85f blue:1 alpha:1];
		case 2:
			return [UIColor colorWithRed:1 green:0.18f blue:0.33f alpha:1];
		default:
			return [UIColor colorWithRed:1 green:0.8f blue:0 alpha:1];
	}
}

%hook PackageCell
%property (nonatomic, retain) UIImageView *icon;
%property (nonatomic, retain) UIImageView *badge;
%property (nonatomic, retain) UIView *compatible_badge;
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
	
	if (self.compatible_badge) {
		self.compatible_badge.frame = CGRectMake(CGRectGetWidth(bounds) - 8, 0, 8, CGRectGetHeight(bounds));
	}
}

- (void) setPackage:(Package *)package asSummary:(bool)summary {
	UIView *content = (UIView *)object_getIvar(self, class_getInstanceVariable([self class], "content_"));
	content.backgroundColor = [prefs colorForKey:@"cellColor"];//[UIColor whiteColor];
	
	[package parse];
	
	NSString *badge;
	if (NSString *mode = [package mode]) {
		badge = ([mode isEqualToString:@"REMOVE"] || [mode isEqualToString:@"PURGE"]) ? @"removing" : @"installing";
	} else if (package.installed) {
		badge = @"installed";
	}
	
	NSUInteger compatible = 0; // 0 = unknown | 1 = compatible | 2 = not compatible
	Database *database = [NSClassFromString(@"Database") sharedInstance];
	if (NSDictionary *bundle = database.cyderCompatibilityList[package.id]) {
		if (NSString *latest = bundle[package.latest]) {
			compatible = [latest isEqualToString:@"Working"] ? 1 : 2;
		}
	}
	
	BOOL commercial = package.isCommercial;
	BOOL removing = [badge isEqualToString:@"removing"];
	
	if (!self.compatible_badge) {
		self.compatible_badge = [[UIView alloc] init];
		self.compatible_badge.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
		[self.contentView addSubview:self.compatible_badge];
	}
	
	if (!self.icon) {
		self.icon = [[UIImageView alloc] initWithImage:package.icon];
		self.icon.frame = CGRectMake(10, 10, 30, 30);
		self.icon.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
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
	self.compatible_badge.backgroundColor = CompatibilityColor(compatible);
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
	//self.backgroundColor = [prefs colorForKey:@"tableColor"];//[UIColor groupTableViewBackgroundColor];
}
-(void)didMoveToWindow {
        %orig;
        //No Separators in the Tables
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        //Set the background Color to a Color or to an Image
        //self.backgroundColor = [UIColor blackColor];
        //Set the Background to an Image, Importing UIImage+ScaledImage.h for this
        if([prefs boolForKey:@"enableImage"]) {    
                UIImage *bgImage = [[UIImage imageWithContentsOfFile: @"/var/mobile/Library/Preferences/Cyder/background.jpg"] imageScaledToSize:[[UIApplication sharedApplication] keyWindow].bounds.size];
                self.backgroundView = [[UIImageView alloc] initWithImage: bgImage];
        }else{
                self.backgroundColor = [prefs colorForKey:@"tableColor"];
        }

}


%end
