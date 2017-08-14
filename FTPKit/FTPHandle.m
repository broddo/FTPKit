#import "FTPHandle.h"
#import "FTPCredentials.h"
#import "NSString+Additions.h"

#include <sys/socket.h>
#include <sys/dirent.h>

@interface FTPHandle()
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSDate *modified;
@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) unsigned long long size;
@property (nonatomic, assign) FTPHandleType type;
@property (nonatomic, assign) int mode;
@property (nonatomic, strong) FTPCredentials *credentials;
@end

@implementation FTPHandle

@synthesize path;
@synthesize modified;
@synthesize group;
@synthesize owner;
@synthesize link;
@synthesize name;
@synthesize size;
@synthesize type;
@synthesize mode;

+ (instancetype)handleAtPath:(NSString *)path attributes:(NSDictionary *)attributes
{
    return [[self alloc] initWithPath:path attributes:attributes];
}

+ (instancetype)handleAtPath:(NSString *)path mlsdAttributes:(NSDictionary *)attributes
{
    return [[self alloc] initWithPath:path mlsdAttributes:attributes];
}

+ (instancetype)handleAtPath:(NSString *)path type:(FTPHandleType)type
{
    return [[self alloc] initWithPath:path type:type];
}

- (instancetype)initWithPath:(NSString *)aPath attributes:(NSDictionary *)aAttributes
{
    self = [super init];
	if (self) {
        self.modified = [aAttributes objectForKey:(id)kCFFTPResourceModDate];
		self.group = [aAttributes objectForKey:(id)kCFFTPResourceGroup];
		self.link = [aAttributes objectForKey:(id)kCFFTPResourceLink];
		self.mode = [[aAttributes objectForKey:(id)kCFFTPResourceSize] intValue];
		self.name = [aAttributes objectForKey:(id)kCFFTPResourceName];
		self.owner = [aAttributes objectForKey:(id)kCFFTPResourceOwner];
		self.size = [[aAttributes objectForKey:(id)kCFFTPResourceSize] unsignedLongLongValue];
		self.type = [[aAttributes objectForKey:(id)kCFFTPResourceType] intValue];
        
        if ([aPath hasPrefix:@"/"]) {
            self.path = [aPath stringByAppendingPathComponent:name];
        } else {
            self.path = [NSString stringWithFormat:@"%@/%@", aPath, name];
        }
	}
	return self;
}

- (instancetype)initWithPath:(NSString *)aPath mlsdAttributes:(NSDictionary *)mAttributes
{
    self = [super init];
    if (self) {
        
        self.modified = [mAttributes objectForKey:@"modify"];
        self.group = nil;
        self.link = nil;
        self.mode = [[mAttributes objectForKey:@"size"] intValue];
        self.name = [mAttributes objectForKey:@"name"];
        self.owner = nil;
        self.size = strtoull([[mAttributes objectForKey:@"size"] UTF8String], NULL, 10);
        self.type = [[mAttributes objectForKey:@"type"] intValue];
        
        if ([aPath hasPrefix:@"/"]) {
            self.path = [aPath stringByAppendingPathComponent:name];
        } else {
            self.path = [NSString stringWithFormat:@"%@/%@", aPath, name];
        }
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)aPath type:(FTPHandleType)aType
{
    self = [super init];
    if (self) {
        self.modified = [NSDate date];
        self.group = nil;
        self.link = nil;
        self.mode = 0;
        self.name = [aPath lastPathComponent];
        self.owner = nil;
        self.size = 0;
        self.type = aType;
        self.path = aPath;
    }
    return self;
}

- (NSString *)permissions
{
	char modeCStr[12];
	strmode(self.mode + DTTOIF(type), modeCStr);
	return [NSString stringWithUTF8String:modeCStr];
}

@end
