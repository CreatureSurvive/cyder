#include <CSPreferences/CSPreferencesProvider.h>
#define prefs [CYPProvider sharedProvider]

@interface CYPProvider : NSObject

+ (CSPreferencesProvider *)sharedProvider;

@end