# YQCloudPropertyManager

[![CI Status](http://img.shields.io/travis/shadeless99/YQCloudPropertyManager.svg?style=flat)](https://travis-ci.org/shadeless99/YQCloudPropertyManager)
[![Version](https://img.shields.io/cocoapods/v/YQCloudPropertyManager.svg?style=flat)](http://cocoapods.org/pods/YQCloudPropertyManager)
[![License](https://img.shields.io/cocoapods/l/YQCloudPropertyManager.svg?style=flat)](http://cocoapods.org/pods/YQCloudPropertyManager)
[![Platform](https://img.shields.io/cocoapods/p/YQCloudPropertyManager.svg?style=flat)](http://cocoapods.org/pods/YQCloudPropertyManager)

## Features

A tool that allows you to configure private  properties of classes on any page without having to passing a class instance.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 8.0 or later

## Installation

YQCloudPropertyManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```objective-c
pod 'YQCloudPropertyManager'
```

## How To Use

* Objective-C

In the class(e.g "YQViewController") which has properties that you would like to change from other pages
```objective-c
#import "YQCloudProperty.h"
```
and then conforms to the <YQCloudPropertyObject> protocol.
declares the property that you want to change like
```objective-c
YQCloudFloat(animation_duration)
```
other kinds of declares see the YQCloudProperty.h file.

Before you use the "animation_duration" property(such as the "viewDidAppear" method),try to invoke the method to load changed values
```objective-c
[[YQCloudPropertyManager sharedManager] loadProperties:self];
```

Now when you change a property of the target class,you should use like this:
```objective-c
Class cls = NSClassFromString(@"YQViewController");
id<YQCloudPropertyObject> object = [[cls alloc] init];
[YQCloudPropertyManager yq_setCGFloat:duration forObject:object name:@"_animation_duration"];
```
The next time when you push or pop to the YQViewController page,the "loadProperties" method are invoked and you will see the changed values.

The full Example project was presented.

## Author

shadeless99, shadeless@126.com

## License

YQCloudPropertyManager is available under the MIT license. See the LICENSE file for more info.
