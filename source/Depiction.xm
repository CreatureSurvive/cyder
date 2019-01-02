#import <objc/runtime.h>
#import <cyder.h>
#import "Classes/SileoDepiction.h"
#import "MMarkdown/MMMarkdown.h"

/* SILEO CRAP*/
static Package *packageData;
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
		//NSError *error;
		NSData *depictionData = [NSData dataWithContentsOfURL: [NSURL URLWithString:nativeDepictionURL]];
		//NSDictionary *json = [NSJSONSerialization JSONObjectWithData:depictionData options:kNilOptions error:&error];
		//CYPackageController *view([[NSClassFromString(@"CYPackageController") alloc] initWithDatabase:[NSClassFromString(@"Database") sharedInstance] forPackage:[package id] withReferrer:[[self referrerURL] absoluteString]]);
		//NSData * myData = [NSData dataWithContentsOfFile:@"/var/mobile/Data.plist"];
		NSDictionary *myData = [self jsonToDict:depictionData];
		//NSDictionary *myData = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Data.plist"];
		UIViewController *nativeDepiction = [SileoDepiction rootViewControllerWithData:myData];
		//nativeDepiction.navigationController.navigationBar.frame.size.height;
		//nativeDepiction.view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
		//[nativeDepiction.view setBackgroundColor:[UIColor yellowColor]];

		nativeDepiction.title = [package getField:@"Name"];
		
		@try{
			nativeDepiction.navigationItem.prompt = [self objectForKeypath:@"tabs.0.views.0.title" inJSON:depictionData];
		}
		@catch (NSException *exception) {
        NSLog(@"No Title Text %@", exception.reason);
		}
		

		

		/*UITableView *depictionView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds];
		depictionView.dataSource = self; 
       	depictionView.delegate = self;
		depictionView.estimatedRowHeight = 44.0;
		depictionView.rowHeight = UITableViewAutomaticDimension;
		[nativeDepiction.view addSubview:depictionView];*/
		 
		
		
		//title.text = [json valueForKeyPath:@"tabs.views.title"];//[json valueForKeyPath:@"DepictionStackView.DepictionSubheaderView.title"];

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
-(NSDictionary *)jsonToDict:(NSData *)json{
	NSMutableArray *jsonData = [[NSArray array] mutableCopy];
	NSMutableDictionary *finalDict = @{}.mutableCopy;
	[finalDict setObject:@"Error" forKey:@"title"];
	//Tagline
	/*NSDictionary *tagLine = [NSDictionary dictionaryWithObject:[self objectForKeypath:@"tabs.0.views.0.title" inJSON:json] forKey:@"title"];
	[jsonData addObject: tagLine];

	//Blurb
	
	//NSString *markDown = [self objectForKeypath:@"tabs.0.views.0.title" inJSON:json];
	NSDictionary *blurb = [NSDictionary dictionaryWithObject:[MMMarkdown HTMLStringWithMarkdown:[self objectForKeypath:@"tabs.0.views.2.markdown" inJSON:json] extensions:MMMarkdownExtensionsGitHubFlavored error:&error] forKey:@"html"];
	[jsonData addObject: blurb];

	//Version
	NSString *versionString = [NSString stringWithFormat: @"%@: %@", [self objectForKeypath:@"tabs.0.views.5.title" inJSON:json] , [self objectForKeypath:@"tabs.0.views.5.text" inJSON:json]];
	NSDictionary *version = [NSDictionary dictionaryWithObject:versionString forKey:@"title"];
	[jsonData addObject: version];*/
	NSArray<NSDictionary *> *tabs = [self objectForKeypath:@"tabs" inJSON:json];
	NSArray<NSDictionary *> *details;
	NSError  *error;

	for (NSDictionary *tab in tabs) {
    	if ([tab[@"tabname"] isEqualToString:@"Details"]) {
        	details = (NSArray*)tab[@"views"];
        	break;
    	}
	}

	for (NSDictionary *view in details) {
    	if ([view[@"class"] isEqualToString:@"DepictionMarkdownView"]) {
        	// add markdown to jsonData
			NSDictionary *md = [NSDictionary dictionaryWithObject:[MMMarkdown HTMLStringWithMarkdown:view[@"markdown"] extensions:MMMarkdownExtensionsGitHubFlavored error:&error] forKey:@"html"];
			[jsonData addObject: md];
    	}
		else if ([view[@"class"] isEqualToString:@"DepictionTableTextView"]) {
        	// some other data
			NSString *titleAndText = [NSString stringWithFormat: @"%@: %@", view[@"title"] , view[@"text"]];
			NSDictionary *normalText = [NSDictionary dictionaryWithObject:titleAndText forKey:@"title"];
			[jsonData addObject: normalText];
    	}
	}


	[finalDict setObject:jsonData forKey:@"data"];
	return finalDict;





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

%new 

%end

