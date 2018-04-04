#ifndef YQCloudProperty_h
#define YQCloudProperty_h
#import "YQCloudPropertyManager.h"

#pragma mark - macros

#define __YQCLOUDPROPERTY_VALUE_COMBINE_(prefix, value) prefix##value           // 字符串连接
#define __YQCLOUDPROPERTY_VALUE_WITH_PREFIX_(value) __YQCLOUDPROPERTY_VALUE_COMBINE_(yqCloud, value)       // 给指定属性增加前缀

// 云控浮点属性声明
#define YQCloudFloat(name) @property (nonatomic, copy) NSNumber<YQCloudFloatProperty> *__YQCLOUDPROPERTY_VALUE_WITH_PREFIX_(name);\
@property (nonatomic, assign) CGFloat name;

// 云控bool属性声明
#define YQCloudBool(name)   @property (nonatomic, copy) NSNumber<YQCloudBoolProperty> *__YQCLOUDPROPERTY_VALUE_WITH_PREFIX_(name);\
@property (nonatomic, assign) BOOL name;

// 云控整型属性声明
#define YQCloudInteger(name)   @property (nonatomic, copy) NSNumber<YQCloudIntegerProperty> *__YQCLOUDPROPERTY_VALUE_WITH_PREFIX_(name);\
@property (nonatomic, assign) NSInteger name;

// 云控字符串属性声明
#define YQCloudString(name) @property (nonatomic, copy) NSString<YQCloudStringProperty> *name;


#pragma mark - protocols

/** 云控属性类协议 */
@protocol YQCloudPropertyObject <NSObject>
@required

@optional
/** 运控标识 */
// 在加载云控属性时, 会根据这个类标识来加载相应属性
// 优先使用实例的标识, 若未实现则使用类标识, 都未实现则使用class名
- (NSString *)cloudPropertyIdentifier;
+ (NSString *)cloudPropertyIdentifier;

/** 缓存过期时间, 默认24小时 */
// 这个值可能被云控修改
@property (nonatomic, assign) NSTimeInterval propertyCacheOverdue;

/** 未声明的云控属性加载 */
// 云控属性的内容, 在类中未声明
- (void)handleUndeclaredCloudProperty:(NSString *)key value:(id)value;

/** 重新加载 */
// 全部云控属性重赋值后, 会调用此方法
- (void)reloadForCloudProperties;

#ifdef YQCLOUDPROPERTY_DEBUG
// 调试方法
/** 类的描述 */
// 用于端内调试配置时, 显示在云控类列表
+ (NSString *)classDescription;

/** 属性描述 */
// 用于端内调试配置时, 显示在云控类列表
+ (NSString *)descriptionOfProperty:(NSString *)propertyName;
#endif  // YQCLOUDPROPERTY_DEBUG
@end



@protocol YQCloudStringProperty
@end

@protocol YQCloudIntegerProperty
@end

@protocol YQCloudFloatProperty
@end

@protocol YQCloudBoolProperty
@end

#endif /* YQCloudProperty_h */
