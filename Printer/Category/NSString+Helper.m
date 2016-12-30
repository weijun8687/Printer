#import "NSString+Helper.h"
#import <CommonCrypto/CommonDigest.h>



@implementation NSString(Helper)

+ (NSString *)MPHexStringFromBytes:(void *)bytes  len:(NSUInteger)len
{
	NSMutableString *output = [NSMutableString string];
	unsigned char *input = (unsigned char *)bytes;
	NSUInteger i;
	for (i = 0; i < len; i++)
		[output appendFormat:@"%02x", input[i]];
	return output;
}

- (BOOL)isEmpty
{
    if (self ==nil) {
        return YES;
    }
	return [self isEmptyIgnoringWhitespace:YES];
}
- (BOOL)isEmptyIgnoringWhitespace:(BOOL)ignoreWhitespace
{
	NSString *toCheck = (ignoreWhitespace) ? [self stringByTrimmingWhitespace] : self;
	return [toCheck isEqualToString:@""];
}
- (NSString *)stringByTrimmingWhitespace
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)MD5Hash
{
	const char *input = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(input, (CC_LONG)strlen(input), result);
    return [NSString MPHexStringFromBytes:result len:CC_MD5_DIGEST_LENGTH];
}
- (NSString *)SHA1Hash
{
	const char *input = [self UTF8String];
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(input, (CC_LONG)strlen(input), result);
    return [NSString MPHexStringFromBytes:result len:CC_SHA1_DIGEST_LENGTH];
}

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}


+ (NSDictionary*)parseFromJsonString:(NSString*)json error:(NSError**)error;{
    if (json ==nil || [json isEmpty]) {
        return nil;
    }
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *array = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    return array;
}

+ (NSString *)stringWithDateSeconds:(NSInteger)seconds{
    
    NSTimeInterval tempMilli = seconds;
    NSTimeInterval sec = tempMilli/1000.0;//这里的.0一定要加上，不然除下来的数据会被截断导致时间不一致
//    NSLog(@"传入的时间戳=%f",sec);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:sec];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    return [formatter stringFromDate:date];
    
}

// 打印时的输出日期格式
+ (NSString *)stringWithDateSecondsForPrinter:(NSInteger)seconds{
    
    NSTimeInterval tempMilli = seconds;
    NSTimeInterval sec = tempMilli/1000.0;//这里的.0一定要加上，不然除下来的数据会被截断导致时间不一致
    //    NSLog(@"传入的时间戳=%f",sec);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:sec];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    return [formatter stringFromDate:date];
    
}


@end

@implementation NSMutableString(MPTidbits)

- (void)trimCharactersInSet:(NSCharacterSet *)aCharacterSet
{
	// trim front
	NSRange frontRange = NSMakeRange(0, 1);
	while ([aCharacterSet characterIsMember:[self characterAtIndex:0]])
		[self deleteCharactersInRange:frontRange];
	
	// trim back
	while ([aCharacterSet characterIsMember:[self characterAtIndex:([self length] - 1)]])
		[self deleteCharactersInRange:NSMakeRange(([self length] - 1), 1)];
}
- (void)trimWhitespace
{
	[self trimCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end

