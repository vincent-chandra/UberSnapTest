//
//  OpenCVWrapper.m
//  UberSnapTest
//
//  Created by Vincent on 10/03/25.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVWrapper.h"

/*
 * add a method convertToMat to UIImage class
 */
@interface UIImage (OpenCVWrapper)
- (void)convertToMat: (cv::Mat *)pMat: (bool)alphaExists;
@end

@implementation UIImage (OpenCVWrapper)

- (void)convertToMat: (cv::Mat *)pMat: (bool)alphaExists {
    if (self.imageOrientation == UIImageOrientationRight) {
        /*
         * When taking picture in portrait orientation,
         * convert UIImage to OpenCV Matrix in landscape right-side-up orientation,
         * and then rotate OpenCV Matrix to portrait orientation
         */
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat, alphaExists);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_CLOCKWISE);
    } else if (self.imageOrientation == UIImageOrientationLeft) {
        /*
         * When taking picture in portrait upside-down orientation,
         * convert UIImage to OpenCV Matrix in landscape right-side-up orientation,
         * and then rotate OpenCV Matrix to portrait upside-down orientation
         */
        UIImageToMat([UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:UIImageOrientationUp], *pMat, alphaExists);
        cv::rotate(*pMat, *pMat, cv::ROTATE_90_COUNTERCLOCKWISE);
    } else {
        /*
         * When taking picture in landscape orientation,
         * convert UIImage to OpenCV Matrix directly,
         * and then ONLY rotate OpenCV Matrix for landscape left-side-up orientation
         */
        UIImageToMat(self, *pMat, alphaExists);
        if (self.imageOrientation == UIImageOrientationDown) {
            cv::rotate(*pMat, *pMat, cv::ROTATE_180);
        }
    }
}
@end

@implementation OpenCVWrapper

+ (NSString *)getOpenCVVersion {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

+ (UIImage *)grayscaleImg:(UIImage *)image {
    cv::Mat mat;
    [image convertToMat: &mat :false];
    
    cv::Mat gray;
    
    NSLog(@"channels = %d", mat.channels());
    
    if (mat.channels() > 1) {
        cv::cvtColor(mat, gray, cv::COLOR_RGB2GRAY);
    } else {
        mat.copyTo(gray);
    }
    
    UIImage *grayImg = MatToUIImage(gray);
    return grayImg;
}

+ (UIImage *)resizeImg:(UIImage *)image :(int)width :(int)height :(int)interpolation {
    cv::Mat mat;
    [image convertToMat: &mat :false];
    
    if (mat.channels() == 4) {
        [image convertToMat: &mat :true];
    }
    
    NSLog(@"source shape = (%d, %d)", mat.cols, mat.rows);
    
    cv::Mat resized;
    
    //    cv::INTER_NEAREST = 0,
    //    cv::INTER_LINEAR = 1,
    //    cv::INTER_CUBIC = 2,
    //    cv::INTER_AREA = 3,
    //    cv::INTER_LANCZOS4 = 4,
    //    cv::INTER_LINEAR_EXACT = 5,
    //    cv::INTER_NEAREST_EXACT = 6,
    //    cv::INTER_MAX = 7,
    //    cv::WARP_FILL_OUTLIERS = 8,
    //    cv::WARP_INVERSE_MAP = 16
    
    cv::Size size = {width, height};
    
    cv::resize(mat, resized, size, 0, 0, interpolation);
    
    NSLog(@"dst shape = (%d, %d)", resized.cols, resized.rows);
    
    UIImage *resizedImg = MatToUIImage(resized);
    
    return resizedImg;
}

+ (UIImage *)changeTemp:(UIImage *)image :(double)temp {
    cv::Mat mat;
    [image convertToMat: &mat :false];
    
    float temperature = -temp; // Example: increase warmth
    Mat adjustedImage = adjustTemperature(mat, temperature);
    
    
    UIImage *adjustedImg2 = MatToUIImage(adjustedImage);
    return adjustedImg2;
}

using namespace cv;
using namespace std;

// Function to adjust image temperature
Mat adjustTemperature(const Mat& input, float temperature) {
    Mat output = input.clone();

    // Split the image into its BGR channels
    vector<Mat> channels;
    split(output, channels);

    // Adjust the blue and red channels based on the temperature value
    // A positive temperature value increases warmth (more red, less blue)
    // A negative temperature value increases coolness (more blue, less red)
    channels[0] = channels[0] * (1 - temperature); // Blue channel
    channels[2] = channels[2] * (1 + temperature); // Red channel

    // Merge the channels back
    merge(channels, output);

    // Ensure pixel values are within the valid range [0, 255]
    output.convertTo(output, -1, 1, 0);

    return output;
}

@end
