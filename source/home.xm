#import <cyder.h>

%hook HomeController

- (void)viewWillAppear: (BOOL)animated {
	%orig;

	CydiaObject *cydia = MSHookIvar<CydiaObject *>(self, "cydia_");

	self.navigationItem.prompt = [NSString stringWithFormat:@"Packages Installed: %lu", [[cydia getInstalledPackages] count]];
	self.navigationController.navigationBar.prefersLargeTitles = YES;
}

// - (void)_setViewportWidth {
// 	%orig;
// 	[self reloadButtonClicked];
// }

// - (id)initWithURL: (NSURL *)url {
// 	return ([url.absoluteString rangeOfString:@"cydia.saurik.com/ui/"].length != 0) ?
// 			%orig([NSURL URLWithString:@"https://creaturecoding.com/"]) :
// 			%orig;
// }

// - (id)initWithRequest:(NSURLRequest *)request {
// 	return ([request.URL.absoluteString rangeOfString:@"cydia.saurik.com/ui/"].length != 0) ?
// 			%orig([NSURLRequest requestWithURL:[NSURL URLWithString:@"https://creaturecoding.com/"]]) :
// 			%orig;
// }

// - (void)setURL:(NSURL *)url {
// 	return ([url.absoluteString rangeOfString:@"cydia.saurik.com/ui/"].length != 0) ?
// 			%orig([NSURL URLWithString:@"https://creaturecoding.com/"]) :
// 			%orig;
// }

%end