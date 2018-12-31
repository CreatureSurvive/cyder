#import "SourceCellContentView.h"
#import <cyder.h>

@implementation SourceCellContentView {
	NSURL *_url;
}

- (instancetype)init {
	if ((self = [super init])) {
		[self commonInit];
	} return self;
}

- (instancetype)initWithSource:(Source *)source {
	if ((self = [super init])) {
		[self commonInit];
		[self refreshWithSource:source];
	} return self;
}

- (void)commonInit {

	self.icon = [[UIImageView alloc] init];
	self.icon.frame = CGRectMake(10, 9, 30, 30);
	self.icon.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
	self.icon.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:self.icon];

	self.name = [[UILabel alloc] init];
	self.name.font = [UIFont systemFontOfSize:16];
	self.name.textColor = [UIColor darkTextColor];
	self.name.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self addSubview:self.name];

	self.uri = [[UILabel alloc] init];
	self.uri.font = [UIFont systemFontOfSize:12];
	self.uri.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:0.5f];
	self.uri.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self addSubview:self.uri];
}

- (void)refreshWithSource:(Source *)source {
	if (source) {
		_url = [source iconURL];
		[NSThread detachNewThreadSelector:@selector(fetchIcon:) toTarget:self withObject:_url];
		self.icon.image = [UIImage imageNamed:@"unknown.png"];
		self.name.text = source.name;
		self.uri.text = source.rooturi;
	} else {
		self.icon.image = [UIImage imageNamed:@"folder.png"];
		self.name.text = [[NSBundle mainBundle] localizedStringForKey:@"ALL_SOURCES" value:nil table:nil];
		self.uri.text = [[NSBundle mainBundle] localizedStringForKey:@"ALL_SOURCES_EX" value:nil table:nil];
	}
	
	[self setNeedsLayout];
}

- (void)fetchIcon:(NSURL *)url {
	
	NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
	NSURLRequest *iconRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
	
	[[session dataTaskWithRequest:iconRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (!error) {
			UIImage *image;
			if ((image = [UIImage imageWithData:data])) {
				[self performSelectorOnMainThread:@selector(setIconIfRelevant:) withObject:@[url, image] waitUntilDone:NO];
			}
		}
	}] resume];
}

- (void)setIconIfRelevant:(NSArray *)data {
	if ([data[0] isEqual:_url]) {
		self.icon.image = (UIImage *)data[1];
	}
}

- (void)layoutSubviews {

	self.name.frame = CGRectMake(44, 8, CGRectGetWidth(self.bounds) - 54, 18);
	self.uri.frame = CGRectMake(44, CGRectGetHeight(self.bounds) - 23, CGRectGetWidth(self.bounds) - 54, 15);
}

@end