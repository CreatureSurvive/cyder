#import <objc/runtime.h>
#import <cyder.h>

%hook Cydia 

- (void)loadData {
	%orig;
	[[NSClassFromString(@"Database") sharedInstance] performSelector:@selector(fetchCyderCompatibilityList)];
}

%end

%hook Database
%property (nonatomic, retain) NSDictionary *cyderCompatibilityList;

%new - (void)fetchCyderCompatibilityList {
	if ([[NSFileManager defaultManager] fileExistsAtPath:COMPATIBILITY_PATH isDirectory:nil]) {
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:COMPATIBILITY_PATH error:nil];

		if ([[NSDate date] timeIntervalSinceDate:[attributes fileModificationDate]] < 15 * 60) {
			self.cyderCompatibilityList = [NSDictionary dictionaryWithContentsOfFile:COMPATIBILITY_PATH];
			return;
		}
	}
	
	NSMutableDictionary *tc_packages = [NSMutableDictionary new];
	
	NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
	NSURL *url =  [NSURL URLWithString:[NSString stringWithFormat:@"https://jlippold.github.io/tweakCompatible/json/iOS/%@.json", [[UIDevice currentDevice] systemVersion]]];
	NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:url];
	
	[[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (!error) {
			
			NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
			for (NSDictionary *package in responseData[@"packages"]) {
				NSString *packageId = package[@"id"];
				
				NSMutableDictionary *versions = [NSMutableDictionary new];
				for (NSDictionary *version in package[@"versions"]) {
					NSString *versionNumber = version[@"tweakVersion"];
					NSString *working = ((NSDictionary *)version[@"outcome"])[@"calculatedStatus"];
					[versions setObject:working forKey:versionNumber];
				}
				
				if ( ![[tc_packages allKeys] containsObject:packageId] ) {
					[tc_packages setObject:versions forKey:packageId];
				}
			}
			
			self.cyderCompatibilityList = [tc_packages copy];
			[tc_packages writeToFile:COMPATIBILITY_PATH atomically:NO];
		}
	}] resume];
}

%end

%hook CyteViewController 

- (void)viewWillAppear:(BOOL)animated {
	%orig;
	self.navigationController.navigationBar.prefersLargeTitles = YES;
}

%end

%hook PackageListController
- (void) didSelectPackage:(Package *)package {
    BOOL isSileoPackage = NO;
    NSString *nativeDepictionURL;
    if ((nativeDepictionURL = [package getField:@"SileoDepiction"])){
        if(nativeDepictionURL && [nativeDepictionURL isKindOfClass:[NSString class]] && ![nativeDepictionURL isEqualToString:@"null"]){
            isSileoPackage = YES;
        }
    }
    
    if (isSileoPackage) {
		NSError *error;
		NSData *depictionData = [NSData dataWithContentsOfURL: [NSURL URLWithString:nativeDepictionURL]];
		NSDictionary *json = [NSJSONSerialization JSONObjectWithData:depictionData options:kNilOptions error:&error];
		//[json writeToFile:@"/var/mobile/Library/Preferences/Cyder/out.txt" atomically:YES];
		NSLog(@"YEETUSDICT %@", json);
		//CYPackageController *view([[NSClassFromString(@"CYPackageController") alloc] initWithDatabase:[NSClassFromString(@"Database") sharedInstance] forPackage:[package id] withReferrer:[[self referrerURL] absoluteString]]);
		UIViewController *nativeDepiction = [[UIViewController alloc] init];
		nativeDepiction.view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
		[nativeDepiction.view setBackgroundColor:[UIColor yellowColor]];
		nativeDepiction.title = [package getField:@"Name"];//json[@""];
		
		@try{
			nativeDepiction.navigationItem.prompt = [self objectForKeypath:@"tabs.0.views.0.title" inJSON:depictionData];
		}
		@catch (NSException *exception) {
        NSLog(@"YEETUSLOG %@", exception.reason);
		}
		

		UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
		@try{
			title.text = [self objectForKeypath:@"tabs.0.views.0.title" inJSON:depictionData];
		}
		@catch (NSException *exception) {
        NSLog(@"YEETUSLOG %@", exception.reason);
		}
		
		//title.text = [json valueForKeyPath:@"tabs.views.title"];//[json valueForKeyPath:@"DepictionStackView.DepictionSubheaderView.title"];
		[title setTextColor:[UIColor blackColor]];
		[title setBackgroundColor:[UIColor clearColor]];
		[title setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]]; 
		[nativeDepiction.view addSubview:title];

		//[view setDelegate:self.delegate];
		[[self navigationController] pushViewController:nativeDepiction animated:YES];
		//NSString *result = [json description];
		//NSLog(@"jYEETUSOURJSON %@", json);
        // open custom sileo view here
    } else {
        %orig;
    }
}

%new
- (id)objectForKeypath:(NSString *)keypath inJSON:(NSData *)json {
	if (!keypath || !json) {return nil;}
	
	__block NSInteger depth = 0;
	NSArray *keys = [keypath componentsSeparatedByString:@"."];
	id result = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
	
	id (^objectAtPath)(NSString *, id) = ^id(NSString *path, id collection) {
		if (collection) {
			
			depth++;
			if ([collection isKindOfClass:[NSDictionary class]]) {
				return [(NSDictionary *)collection objectForKey:path];
			}

			else if ([collection isKindOfClass:[NSArray class]]) {
				return [(NSArray *)collection objectAtIndex:[path integerValue]];
			}
		}
		
		return nil;
	};

	while (depth < keys.count) {
		
		if (!result) { return nil; }
		
		result = objectAtPath(keys[depth], result);
	}
	
	return result;
}

%new -(CGFloat)tableView: (UITableView *)tableView heightForHeaderInSection: (NSInteger)section {
	return ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) ? 0 : 36.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	static NSString *prefix = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		prefix = [[[NSBundle mainBundle] localizedStringForKey:@"NEW_AT" value:nil table:nil] ? : @"" stringByReplacingOccurrencesOfString:@"%@" withString:@""];
	});

	return [%orig stringByReplacingOccurrencesOfString: prefix withString:@""];
}

%end

%hook PackageSettingsController

- (NSString *)tableView: (UITableView *)tableView titleForFooterInSection: (NSInteger)section {
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

%end

/*
// UIKIT HOOKS
*/

%hook UINavigationController

- (void)viewDidLoad {
    %orig;
    self.navigationBar.prefersLargeTitles = YES;
    self.navigationBar.topItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
}

%end

%hook UINavigationBar

- (BOOL)_wantsLargeTitleDisplayed {
	return YES;
}
-(void)layoutSubviews {
        %orig;
        //Sets bar style, removes white Bar
        [self setBarStyle:UIBarStyleBlack];

        //Sets title Text to white

        self.titleTextAttributes = @{NSForegroundColorAttributeName: [prefs colorForKey:@"navTextColor"]};

        //Tints the Buttons
        self.tintColor = [prefs colorForKey:@"navTintColor"];//[UIColor greenColor];

        //Hide background Image of NavBar, Makes black/ background image stand out
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];

        //Set BackgroundColor of NavBar, clear for backgroundImage
        [self setBackgroundColor:[prefs colorForKey:@"navBackgroundColor"]];


        //Shadow ¯\_(ツ)_/¯ not sure what this does, but uhh... the code doesnt work without it.
        //self.shadowImage = [UIImage new];

        //Sets the NavBar transparent, scrolling etc.
        //Keep this on, otherwise it breaks the background of searching
        self.translucent = YES;
}

%end

%hook UIStatusBar

-(void)layoutSubviews {
        %orig;
        self.foregroundColor = [prefs colorForKey:@"statusColor"];
		self.tag = 199;
}

%end
//iPX
%hook _UIStatusBar


-(void)layoutSubviews {
        %orig;
        self.foregroundColor = [prefs colorForKey:@"statusColor"];
		self.tag = 199;
}

%end

%hook UIStatusBarBackgroundView

//set to clear when using background option, or blurred
-(void)layoutSubviews {
        %orig;
        self.backgroundColor = [prefs colorForKey:@"navBackgroundColor"];
		self.tag = 199;

}
%end

%hook _UIBarBackground
- (void) setBackgroundColor: (UIColor *)color {
        %orig([prefs colorForKey:@"navBackgroundColor"]);
}
- (void) layoutSubviews{
	%orig;
	self.shim_shadowView.hidden =YES;
}
%end

%hook UIVisualEffectView

- (void)setBackgroundEffects: (NSArray *)effects {
    if ([self.superview isKindOfClass:[NSClassFromString(@"_UIBarBackground") class]]) {
        self.backgroundColor = [UIColor clearColor];
    } else {
        %orig;
    }
}
%end

%hook UITabBar
-(void)layoutSubviews{
	%orig;
	self.tintColor = [prefs colorForKey:@"navTintColor"];
	self.backgroundColor = [UIColor clearColor];
}
%end

%hook UIViewController

- (void)viewWillAppear: (BOOL)animated {
    %orig;
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    self.navigationController.navigationBar.topItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
}

%end

%hook UITableViewCellSelectedBackground

- (id)initWithFrame: (CGRect)frame {
	frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(2.5, 5, 2.5, 5));
	if ((self = %orig(frame))) {
		self.layer.cornerRadius = 13;
		self.layer.masksToBounds = YES;
	}

	return self;
}

%end

%hook UISwipeActionStandardButton

- (id)initWithFrame: (CGRect)frame {
	if ((self = %orig)) {
		self.layer.cornerRadius = 13;
		self.layer.masksToBounds = YES;
		self.frame = UIEdgeInsetsInsetRect(self.frame, UIEdgeInsetsMake(5, 0, 0, 0));
	}
	return self;
}

%end

%hook UISwipeActionPullView

-(id)initWithCellEdge: (NSUInteger)edge style: (NSUInteger)style {
	if ((self = %orig)) {
		self.layer.cornerRadius = 13;
		self.layer.masksToBounds = YES;
	}
	return self;
}

%end

%hook UITableViewHeaderFooterView

- (void)layoutSubviews {
	%orig;
	self.backgroundView.backgroundColor = [prefs colorForKey:[prefs boolForKey:@"enableImage"] ? @"navBackgroundColor" : @"tableColor"];//[UIColor groupTableViewBackgroundColor];
	self.textLabel.font = [UIFont boldSystemFontOfSize:18];
	self.textLabel.textColor = [prefs colorForKey:@"navTextColor"];
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
