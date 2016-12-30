#import <Foundation/Foundation.h>

@interface NSString(Helper)

+ (NSString *)MPHexStringFromBytes:(void *)bytes  len:(NSUInteger)len;

- (BOOL)isEmpty;
- (BOOL)isEmptyIgnoringWhitespace:(BOOL)ignoreWhitespace;
- (NSString *)stringByTrimmingWhitespace;

- (NSString *)MD5Hash;
- (NSString *)SHA1Hash;

- (NSString *)trim;


- (NSString *)md5;

+ (NSDictionary*)parseFromJsonString:(NSString*)json error:(NSError**)error;

// 将时间的毫秒值转换成时间类型的字符串
+ (NSString *)stringWithDateSeconds:(NSInteger)seconds;

// 打印时的输出日期格式
+ (NSString *)stringWithDateSecondsForPrinter:(NSInteger)seconds;


@end

@interface NSMutableString(MPTidbits)

- (void)trimCharactersInSet:(NSCharacterSet *)aCharacterSet;

- (void)trimWhitespace;


@end
