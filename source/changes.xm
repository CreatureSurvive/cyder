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

- (void)reloadData {
	[self.refreshControl endRefreshing];
	%orig;
}

%end