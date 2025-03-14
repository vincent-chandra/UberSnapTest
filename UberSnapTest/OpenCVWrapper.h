//
//  OpenCVWrapper.h
//  UberSnapTest
//
//  Created by Vincent on 10/03/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
+ (NSString *)getOpenCVVersion;
+ (UIImage *)grayscaleImg:(UIImage *)image;
+ (UIImage *)resizeImg:(UIImage *)image :(int)width :(int)height :(int)interpolation;
+ (UIImage *)changeTemp:(UIImage *)image :(double)temp;
@end

NS_ASSUME_NONNULL_END
