#import <UIKit/UIKit.h>
#define YQCLOUDPROPERTY_DEBUG

@protocol YQCloudPropertyObject;

#define YQPROPERTYMANAGER   [YQCloudPropertyManager sharedManager]

typedef NS_ENUM(NSInteger, YQCloudPropertyType)
{
    YQCloudPropertyUnknown  = 0,
    YQCloudPropertyInteger  = 1,
    YQCloudPropertyFloat    = 2,
    YQCloudPropertyBool     = 3,
    YQCloudPropertyString   = 4,
};

@interface YQCloudPropertyManager : NSObject

/** 全局共享实例 */
+ (YQCloudPropertyManager *)sharedManager;

/** 为指定对象加载云控属性 */
- (BOOL)loadProperties:(id<YQCloudPropertyObject>)object;

/** 增加一个云控属性字典 */
- (void)addProperties:(NSDictionary *)propertyDict forIdentifier:(NSString *)identifier;

/** 移除一个云控属性字典 */
- (void)removePropertiesForIdentifier:(NSString *)identifier;

/** 获取指定对象的云控属性字典 */
+ (NSDictionary *)cloudDictionaryForObject:(id<YQCloudPropertyObject>)object;

/** 获取指定对象的云控json串 */
+ (NSString *)cloudJsonStringForObject:(id<YQCloudPropertyObject>)object;

/** 设置CGFloat值 */
+ (BOOL)yq_setCGFloat:(CGFloat)value forObject:(id<YQCloudPropertyObject>)object name:(NSString *)name;

/** 设置bool值 */
+ (BOOL)yq_setBool:(BOOL)value forObject:(id<YQCloudPropertyObject>)object name:(NSString *)name;

/** 设置整型值 */
+ (BOOL)yq_setNSInteger:(NSInteger)value forObject:(id<YQCloudPropertyObject>)object name:(NSString *)name;

/** 遍历指定对象的云控属性 */
+ (void)enumCloudPropertyForObject:(id<YQCloudPropertyObject>)object handler:(void(^)(NSString *name, YQCloudPropertyType type))handler;

/** 获取成员变量的偏移指针 */
+ (void *)pointerOfVar:(NSString *)name forObject:(id<YQCloudPropertyObject>)object;

/** 获取指定对象的云控标识 */
+ (NSString *)cloudIdentifierOfObject:(id<YQCloudPropertyObject>)object;

#pragma mark - debug methods
#ifdef YQCLOUDPROPERTY_DEBUG
/** 获取全部云控类名 */
+ (void)getClassesOfCloudProperty:(void(^)(NSArray <NSString *> *))completion;

/** 增加一个编辑后的云控属性字典 */
- (void)addLocalProperties:(NSDictionary *)propertyDict forIdentifier:(NSString *)identifier;

/** 移除一个编辑后的云控属性字典 */
- (void)removeLocalPropertiesForIdentifier:(NSString *)identifier;
#endif  // YQCLOUDPROPERTY_DEBUG
@end
