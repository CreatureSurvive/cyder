#import <cyder.h>

%hook SearchController

- (void)viewDidAppear: (BOOL)animated {
	%orig;
	UITableView *table = (UITableView *)object_getIvar(self, class_getInstanceVariable([self class], "list_"));
	[table setRowHeight:44];
}

%new -(CGFloat)tableView: (UITableView *)tableView heightForHeaderInSection: (NSInteger)section {
	return 0;
}

%end