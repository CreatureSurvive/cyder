#import <cyder.h>

%hook CydiaLoadingViewController

-(void)loadView {
	%orig;
	UIView *background = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	background.backgroundColor = [UIColor whiteColor];
	NSMutableParagraphStyle *attributedStringParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	attributedStringParagraphStyle.alignment = NSTextAlignmentCenter;

	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Cydia\nby: Saurik"]];

	[attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:36.0] range:NSMakeRange(0, 6)];
	[attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:18.0] range:NSMakeRange(6, 10)];
	[attributedString addAttribute:NSParagraphStyleAttributeName value:attributedStringParagraphStyle range:NSMakeRange(0, 16)];
	[attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor darkTextColor] range:NSMakeRange(0, 6)];
	[attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(6, 10)];

	UILabel *launchLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	launchLabel.attributedText = attributedString;
	launchLabel.backgroundColor = [UIColor clearColor];
	launchLabel.numberOfLines = 2;
	[launchLabel sizeToFit];
	launchLabel.center = background.center;

	[background addSubview:launchLabel];
	[[self view] addSubview:background];
}

%end
