#import "SileoDepiction.h"
#import <cyder.h>
#import "../MMarkdown/MMMarkdown.h"


@implementation SileoDepiction

#pragma mark UIViewController

+ (instancetype)rootViewControllerWithPlist:(NSString *)plist {
	return [SileoDepiction rootViewControllerWithData:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plist ofType:@"plist"]]];
}

+ (instancetype)rootViewControllerWithData:(RootDataSource)data {
	return [SileoDepiction rootViewControllerWithData:data cellStyle:UITableViewCellStyleSubtitle];
}

+ (instancetype)rootViewControllerWithData:(RootDataSource)data cellStyle:(UITableViewCellStyle)style {
	SileoDepiction *controller = [SileoDepiction new];
	controller.data = data;
	controller.cellStyle = style;
	return controller;
}

+ (instancetype)rootViewControllerWithJSON:(NSURL *)link{
	SileoDepiction *controller = [SileoDepiction new];
	[controller loadFromSileoDepictionURL:link];
	return controller;
}

- (void)loadFromSileoDepictionURL:(NSURL *)jsonLink{
	NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
	NSURLRequest *request =  [[NSURLRequest alloc] initWithURL:jsonLink];
	
	[[session dataTaskWithRequest:request completionHandler:^(NSData *json, NSURLResponse *response, NSError *error) {
		if (error) return;
		dispatch_async(dispatch_get_main_queue(), ^{
	
		NSMutableArray *jsonData = [[NSArray array] mutableCopy];
		NSMutableDictionary *finalDict = @{}.mutableCopy;
		//[finalDict setObject:@"Error" forKey:@"title"];

		NSArray<NSDictionary *> *tabs = [SileoDepiction objectForKeypath:@"tabs" inJSON:json];
		NSArray<NSDictionary *> *details;

		for (NSDictionary *tab in tabs) {
			if ([tab[@"tabname"] isEqualToString:@"Details"]) {
				details = (NSArray*)tab[@"views"];
				break;
			}
		}

		for (NSDictionary *view in details) {
			if ([view[@"class"] isEqualToString:@"DepictionMarkdownView"]) {
				// add markdown to jsonData
				NSDictionary *md = [NSDictionary dictionaryWithObject:[MMMarkdown HTMLStringWithMarkdown:view[@"markdown"] extensions:MMMarkdownExtensionsGitHubFlavored error:nil] forKey:@"html"];
				[jsonData addObject: md];
			}
			else if ([view[@"class"] isEqualToString:@"DepictionSubheaderView"]) {
				// some other data
				NSDictionary *title = [NSDictionary dictionaryWithObject:view[@"title"] forKey:@"title"];
				[jsonData addObject: title];
			}
			else if ([view[@"class"] isEqualToString:@"DepictionTableTextView"]) {
				// some other data
				NSString *titleAndText = [NSString stringWithFormat: @"%@: %@", view[@"title"] , view[@"text"]];
				NSDictionary *normalText = [NSDictionary dictionaryWithObject:titleAndText forKey:@"title"];
				[jsonData addObject: normalText];
			}
		}


		[finalDict setObject:jsonData forKey:@"data"];
		[self setData:finalDict];
		});
	}] resume];
}

- (void)loadView {
	[super loadView];
	
	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	self.view = self.tableView;
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self dataSource].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"CustomTableViewCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:self.cellStyle reuseIdentifier:identifier];
	}
	
	DataSourceEntry data = [self dataForIndexPath:indexPath];
	
	if (data[@"title"])
		cell.textLabel.text = data[@"title"];
	else if (data[@"html"])
		cell.textLabel.attributedText = [self attributedTextFromHTML:data[@"html"]];

	if([prefs boolForKey:@"enableImage"]) {    
				cell.backgroundColor = [UIColor clearColor];
		}else{
				cell.backgroundColor = [prefs colorForKey:@"tableColor"];
		}
	
	cell.detailTextLabel.text = data[@"subtitle"];
	cell.imageView.image = [[UIImage imageNamed:data[@"icon"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	cell.textLabel.textColor = [prefs colorForKey:@"textColor"];
	cell.detailTextLabel.textColor = [prefs colorForKey:@"textColor"];
	cell.imageView.tintColor = [prefs colorForKey:@"navTintColor"];
	cell.textLabel.numberOfLines = 0;
	cell.detailTextLabel.numberOfLines = 0;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	/*[tableView deselectRowAtIndexPath:indexPath animated:YES];
	DataSourceEntry data = [self dataForIndexPath:indexPath];
	UIViewController *viewController;
	if ([data[@"detail"] isEqualToString:@"pathVC"])
		viewController = [[CSBSPathViewController alloc] initWithPath:data[@"subtitle"]];
	if (viewController)
		[self.navigationController pushViewController:viewController animated:YES];*/
}

#pragma mark Internal

- (void)setData:(RootDataSource)data {
	if (_data != data) {
		_data = data;
		//Don't need this, since I set the name to package name in Depiction.xm
		//self.title = data[@"title"];
		[self.tableView reloadData];
	}
}

- (DataSourceEntry)dataForIndexPath:(NSIndexPath *)indexPath {
	return [self dataSource][indexPath.row];
}

- (DataSource)dataSource {
	return self.data[@"data"];
}

- (NSAttributedString *)attributedTextFromHTML:(NSString *)html {
	html = [html stringByAppendingString:@"<style>body{font-family: -apple-system!important;}</style>"];
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
	[string addAttribute:NSForegroundColorAttributeName value:[prefs colorForKey:@"textColor"] range:NSMakeRange(0, string.length)];
	return string;
}

//Search JSON
+ (id)objectForKeypath:(NSString *)keypath inJSON:(NSData *)json {
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

@end