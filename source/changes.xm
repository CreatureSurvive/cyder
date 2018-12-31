#import <cyder.h>

%hook ChangesController
%property(nonatomic, retain) UIRefreshControl *refreshControl;

- (void)viewDidLoad {
	%orig;
	UITableView *table = (UITableView *)object_getIvar(self, class_getInstanceVariable([self class], "list_"));
	self.refreshControl = [[UIRefreshControl alloc] init];
	table.refreshControl = self.refreshControl;
	[self.refreshControl addTarget:self action:@selector(refreshButtonClicked) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear: (BOOL)animated {
	%orig;
	
	self.navigationItem.prompt = [NSString stringWithFormat:@"Total Packages: %lu", [[[NSClassFromString(@"Database") sharedInstance] packages] count]];
	
	if ([[self delegate] updating]) { [self.refreshControl beginRefreshing]; }
}

- (void)reloadData {
	[self.refreshControl endRefreshing];
	%orig;
}

- (void)refreshButtonClicked {
	%orig;
	[self.refreshControl beginRefreshing];
}

- (void)cancelButtonClicked {
	%orig;
	[self.refreshControl endRefreshing];
}


%end