#import "FTPRequest.h"
#import "FTPHandle.h"
#import "FTPCredentials.h"

@interface FTPRenameRequest : FTPRequest

+ (instancetype)requestWithCredentials:(FTPCredentials *)credentials sourcePath:(NSString *)sourcePath destPath:(NSString *)destPath;

- (instancetype)initWithCredentials:(FTPCredentials *)credentials sourcePath:(NSString *)sourcePath destPath:(NSString *)destPath;

@end