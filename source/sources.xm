#import <cyder.h>

%hook SourcesController
%property(nonatomic, retain) UIRefreshControl *refreshControl;

- (void)viewDidLoad {
	UITableView *table = (UITableView *)object_getIvar(self, class_getInstanceVariable([self class], "list_"));
	self.refreshControl = [[UIRefreshControl alloc] init];
	table.refreshControl = self.refreshControl;
	[self.refreshControl addTarget:self action:@selector(refreshButtonClicked) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear: (BOOL)animated {
	%orig;

	if ([[self delegate] updating]) { [self.refreshControl beginRefreshing]; }

	self.navigationItem.prompt = [NSString stringWithFormat:@"Total Sources: %lu", [[[NSClassFromString(@"Database") sharedInstance] sources] count]];
	self.navigationController.navigationBar.prefersLargeTitles = YES;

	[self performSelector:@selector(setNavbarItems)];
}

- (void)showAddSourcePrompt {

	NSString *pasteboard = [[UIPasteboard generalPasteboard] string];
	NSMutableArray *foundURLs = [NSMutableArray new];
	Cydia *delegate = [self delegate];

	if (pasteboard.length) {

		NSString *pattern = @"https?://([-\\w\\.]+)+(:\\d+)?(/([\\w/_\\.]*(\\?\\S+)?)?)?";
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
		NSArray *matches = [regex matchesInString:pasteboard options:0 range:NSMakeRange(0, [pasteboard length])];

		for (NSTextCheckingResult *match in matches) {    
			NSString* substringForMatch = [pasteboard substringWithRange:match.range];

			NSURL *candidateURL = [NSURL URLWithString:substringForMatch];
			if (candidateURL && candidateURL.scheme && candidateURL.host) {
				[foundURLs addObject:substringForMatch];
			}
		}
	}

	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add Source" message:@"" preferredStyle:UIAlertControllerStyleAlert];

	[alertController addTextFieldWithConfigurationHandler:^(UITextField *field) {
		field.text = @"https://";
		field.clearButtonMode = UITextFieldViewModeWhileEditing;
	}];

	[alertController addAction:[UIAlertAction actionWithTitle:@"Add Source" style:UIAlertActionStyleDefault handler:^(UIAlertAction *set) {
		NSURL *candidateURL = [NSURL URLWithString:alertController.textFields[0].text];
		if (candidateURL && candidateURL.scheme && candidateURL.host) {
			[delegate addTrivialSource:candidateURL.absoluteString];
			[delegate syncData];
		}
	}]];

	[alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

	if (foundURLs.count) {
		[alertController addAction:[UIAlertAction actionWithTitle:@"Add Sources From PasteBoard" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			for (id url in foundURLs) { [delegate addTrivialSource:url]; }
			[delegate syncData];
		}]];
	}

	[[self navigationController] presentViewController:alertController animated:YES completion:nil];
}

- (void)refreshButtonClicked {
	%orig;
	[self performSelector:@selector(setNavbarItems)];
	[self.refreshControl beginRefreshing];
}

- (void)cancelButtonClicked {
	%orig;
	[self performSelector:@selector(setNavbarItems)];
	[self.refreshControl endRefreshing];
}

- (void)addButtonClicked {
	%orig;
	[self performSelector:@selector(setNavbarItems)];
}

- (void)editButtonClicked {
	%orig;
	[self performSelector:@selector(setNavbarItems)];
}

- (void)reloadData {
	%orig;
	[self performSelector:@selector(setNavbarItems)];
	[self.refreshControl endRefreshing];
}

- (void)updateButtonsForEditingStatusAnimated:(BOOL)animated {}

%new - (void)setNavbarItems {
	static __strong UIBarButtonItem *addButton, *refreshButton, *stopButton, *copyButton;
	addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showAddSourcePrompt)];
	refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonClicked)];
	stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelButtonClicked)];
	copyButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(copyButtonClicked)];
	self.navigationItem.leftBarButtonItems = @[addButton, [[self delegate] updating] ? stopButton : refreshButton];
	self.navigationItem.rightBarButtonItems = @[copyButton];
	self.navigationItem.title = [[NSBundle mainBundle] localizedStringForKey:@"SOURCES" value:nil table:nil];
}

%new -(void)copyButtonClicked {
	NSMutableString *sources = [NSMutableString new];
	NSMutableArray *urls = [NSMutableArray new];
	for (Source *source in [[NSClassFromString(@"Database") sharedInstance] sources]) {
		[sources appendString:[[source rooturi] stringByAppendingString:@"\n"]];
		[urls addObject:[NSURL URLWithString:[source rooturi]]];
	}
	
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Source List:" message:sources preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:@"Copy to Pasteboard" style:UIAlertActionStyleDefault handler:^(UIAlertAction *set) {
		[[UIPasteboard generalPasteboard] setString:sources];
		[[UIPasteboard generalPasteboard] setURLs:urls];
	}]];
	[alertController addAction:[UIAlertAction actionWithTitle:@"Open In" style:UIAlertActionStyleDefault handler:^(UIAlertAction *set) {
		UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:@[sources] applicationActivities:nil];  
		[activityViewControntroller setExcludedActivityTypes:@[]];  
		[[self navigationController] presentViewController:activityViewControntroller animated:true completion:nil];  
	}]];
	[alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

	[[self navigationController] presentViewController:alertController animated:YES completion:nil];
}

%end