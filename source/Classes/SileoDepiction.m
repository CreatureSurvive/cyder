#import "SileoDepiction.h"
#import <cyder.h>

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

	cell.backgroundColor = [prefs colorForKey:@"cellColor"];
	cell.detailTextLabel.text = data[@"subtitle"];
	cell.imageView.image = [[UIImage imageNamed:data[@"icon"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

	cell.detailTextLabel.textColor = [prefs colorForKey:@"textColor"];//[UIColor lightGrayColor];
	cell.imageView.tintColor = [prefs colorForKey:@"navTintColor"];//[UIColor blueColor];
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
		self.title = data[@"title"];
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
	html = [html stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: -apple-system; color:%@}</style>", [prefs stringForKey:@"textColor"]]];
	return [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
}

@end