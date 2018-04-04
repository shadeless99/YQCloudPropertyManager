#import "YQCloudPropertyManager.h"
#import "YQCloudProperty.h"
#import <objc/runtime.h>

/** 全局实例 */
static YQCloudPropertyManager *g_cloudPropertyManager = nil;

@interface YQCloudPropertyManager()
{
    /** 云控属性字典 */
    NSMutableDictionary     *_propertyDict;
    
#ifdef YQCLOUDPROPERTY_DEBUG
    /** 本地属性字典(编辑后) */
    NSMutableDictionary     *_localPropertyDict;
#endif  // YQCLOUDPROPERTY_DEBUG
}

/** 根据云控属性值获取成员变量名 */
+ (NSString *)varNameOfCloudProperty:(NSString *)propertyName;

/** 根据云控属性值获取常规属性名 */
+ (NSString *)nameOfCloudProperty:(NSString *)propertyName;

/** 保存缓存 */
- (void)saveCache;

/** 加载缓存 */
- (void)loadCache;

/** 缓存文件全路径 */
+ (NSString *)cacheFile;

/** 缓存文件夹 */
+ (NSString *)cachePath;

#ifdef YQCLOUDPROPERTY_DEBUG
/** 本地属性编辑缓存文件 */
+ (NSString *)localCacheFile;
#endif  // SYQCLOUDPROPERTY_DEBUG
@end

@implementation YQCloudPropertyManager

#pragma mark -  override
- (instancetype)init
{
    self = [super init];
    if( self )
    {
        _propertyDict = [[NSMutableDictionary alloc] init];
#ifdef YQCLOUDPROPERTY_DEBUG
        _localPropertyDict = [[NSMutableDictionary alloc] init];
#endif  // YQCLOUDPROPERTY_DEBUG
        [self loadCache];
    }
    return self;
}


#pragma mark - methods
/** 全局共享实例 */
+ (YQCloudPropertyManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_cloudPropertyManager = [[YQCloudPropertyManager alloc] init];
    });
    return g_cloudPropertyManager;
}

/** 为指定对象加载云控属性 */
- (BOOL)loadProperties:(id<YQCloudPropertyObject>)object
{
    BOOL bRet = FALSE;
    NSString *strIdentifier = [[self class] cloudIdentifierOfObject:object];
    if( !strIdentifier )
    {
        return FALSE;
    }
    NSDictionary *propertyDict = nil;
#ifdef YQCLOUDPROPERTY_DEBUG
    propertyDict = [_localPropertyDict objectForKey:strIdentifier];
#endif  // YQCLOUDPROPERTY_DEBUG
    if( !propertyDict )
    {
        propertyDict = [_propertyDict objectForKey:strIdentifier];
    }
    if( !propertyDict )
    {
        return FALSE;
    }
    NSArray *arTemp = propertyDict.allKeys;
    if( !arTemp.count )
    {
        return FALSE;
    }
    NSMutableArray *arAllKeys = [[NSMutableArray alloc] initWithArray:arTemp];  // 云控属性的所有key
    NSMutableArray *arKeysProcessed = [[NSMutableArray alloc] init];            // 已经处理的所有key
    
    [[self class] enumCloudPropertyForObject:object handler:^(NSString *name, YQCloudPropertyType type) {
        NSString *strVarName = [[self class] varNameOfCloudProperty:name];    // 成员变量名
        id cloudObj = [propertyDict objectForKey:name];
        switch(type)
        {
            case YQCloudPropertyInteger:
                // 整型数
                if( [cloudObj isKindOfClass:[NSNumber class]] )
                {
                    NSNumber *number = cloudObj;
                    NSInteger nValue = [number integerValue];
                    [[self class] setNSInteger:nValue forObject:object name:strVarName];
                }
                break;
            case YQCloudPropertyBool:
                // bool值
                if( [cloudObj isKindOfClass:[NSNumber class]] )
                {
                    NSNumber *number = cloudObj;
                    BOOL bValue = [number boolValue];
                    [[self class] setBool:bValue forObject:object name:strVarName];
                }
                break;
            case YQCloudPropertyFloat:
                // 浮点数
                if( [cloudObj isKindOfClass:[NSNumber class]] )
                {
                    NSNumber *number = cloudObj;
                    CGFloat fValue = [number floatValue];
                    [[self class] setCGFloat:fValue forObject:object name:strVarName];
                }
                break;
            case YQCloudPropertyString:
                // 字符串
                if( [cloudObj isKindOfClass:[NSString class]] )
                {
                    NSObject *obj = object;
                    [obj setValue:cloudObj forKey:name];
                }
                break;
            case YQCloudPropertyUnknown:
            default:
                break;
        }
    }];
    
    if( arKeysProcessed.count )
    {
        [arAllKeys removeObjectsInArray:arKeysProcessed];
        bRet = TRUE;
    }
    else
    {
        bRet = FALSE;
    }
    if( [object respondsToSelector:@selector(handleUndeclaredCloudProperty:value:)] )
    {
        // 处理额外key
        for( NSString *strKey in arAllKeys )
        {
            id value = [propertyDict objectForKey:strKey];
            [object handleUndeclaredCloudProperty:strKey value:value];
        }
    }
    if( [object respondsToSelector:@selector(reloadForCloudProperties)] )
    {
        [object reloadForCloudProperties];
    }
    return TRUE;
}

/** 增加一个云控属性字典 */
- (void)addProperties:(NSDictionary *)propertyDict forIdentifier:(NSString *)identifier
{
    if( !propertyDict )
    {
        [self removePropertiesForIdentifier:identifier];
        return;
    }
    [_propertyDict setObject:propertyDict forKey:identifier];
    [self saveCache];
}

/** 移除一个云控属性字典 */
- (void)removePropertiesForIdentifier:(NSString *)identifier
{
    [_propertyDict removeObjectForKey:identifier];
    [self saveCache];
}


/** 获取指定对象的云控属性字典 */
+ (NSDictionary *)cloudDictionaryForObject:(id<YQCloudPropertyObject>)object
{
    NSString *strIdentifier = [self cloudIdentifierOfObject:object];
    if( !strIdentifier.length )
    {
        return nil;
    }
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    [self enumCloudPropertyForObject:object handler:^(NSString *name, YQCloudPropertyType type) {
        NSString *strVarName = [[self class] varNameOfCloudProperty:name];    // 成员变量名
        switch(type)
        {
            case YQCloudPropertyInteger:
                // 整型数
            {
                NSInteger *ptrValue = [self pointerOfVar:strVarName forObject:object];
                if( !ptrValue )
                {
                    break;
                }
                NSNumber *number = [NSNumber numberWithInteger:*ptrValue];
                [ret setObject:number forKey:name];
            }
                break;
            case YQCloudPropertyBool:
            {
                // bool值
                BOOL *ptrValue = [self pointerOfVar:strVarName forObject:object];
                if( !ptrValue )
                {
                    break;
                }
                NSNumber *number = [NSNumber numberWithBool:*ptrValue];
                [ret setObject:number forKey:name];
            }
                break;
            case YQCloudPropertyFloat:
            {
                // 浮点数
                CGFloat *ptrValue = [self pointerOfVar:strVarName forObject:object];
                if( !ptrValue )
                {
                    break;
                }
                NSNumber *number = [NSNumber numberWithFloat:*ptrValue];
                [ret setObject:number forKey:name];
            }
                break;
            case YQCloudPropertyString:
            {
                // 字符串
                NSObject *obj = object;
                id value = [obj valueForKey:name];
                if( [value isKindOfClass:[NSString class]] )
                {
                    [ret setObject:value forKey:name];
                }
            }
            case YQCloudPropertyUnknown:
            default:
                break;
        }
    }];
    
    if( !ret )
    {
        return nil;
    }
    NSMutableDictionary *final = [[NSMutableDictionary alloc] init];
    [final setObject:ret forKey:strIdentifier];
    return final;
}

/** 获取指定对象的云控json串 */
+ (NSString *)cloudJsonStringForObject:(id<YQCloudPropertyObject>)object
{
    NSDictionary *infoDict = [self cloudDictionaryForObject:object];
    if( !infoDict )
    {
        return nil;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:infoDict options:0 error:nil];
    if( !data )
    {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

/** 保存属性更改 */
+ (void)savePropertiesForObject:(id<YQCloudPropertyObject>)object {
    NSDictionary *dict = [self cloudDictionaryForObject:object];
    NSString *strIdentifier = [self cloudIdentifierOfObject:object];
    [[YQCloudPropertyManager sharedManager] addLocalProperties:[dict objectForKey:strIdentifier] forIdentifier:strIdentifier];
}

+ (BOOL)yq_setCGFloat:(CGFloat)value forObject:(id<YQCloudPropertyObject>)object name:(NSString *)name {
    BOOL flag = [self setCGFloat:value forObject:object name:name];
    [self savePropertiesForObject:object];
    return flag;
}

+ (BOOL)yq_setBool:(BOOL)value forObject:(id<YQCloudPropertyObject>)object name:(NSString *)name {
    BOOL flag = [self setBool:value forObject:object name:name];
    [self savePropertiesForObject:object];
    return flag;
}

+ (BOOL)yq_setNSInteger:(NSInteger)value forObject:(id<YQCloudPropertyObject>)object name:(NSString *)name {
    BOOL flag = [self setNSInteger:value forObject:object name:name];
    [self savePropertiesForObject:object];
    return flag;
}

/** 设置CGFloat值 */
+ (BOOL)setCGFloat:(CGFloat)value forObject:(id<YQCloudPropertyObject>)object name:(NSString *)name
{
    CGFloat *ptrValue = [self pointerOfVar:name forObject:object];
    if( ptrValue )
    {
        *ptrValue = value;
    }
    return YES;
}


/** 设置bool值 */
+ (BOOL)setBool:(BOOL)value forObject:(id<YQCloudPropertyObject>)object name:(NSString *)name
{
    BOOL *ptrValue = [self pointerOfVar:name forObject:object];
    if( ptrValue )
    {
        *ptrValue = value;
    }
    return YES;
}

/** 设置整型值 */
+ (BOOL)setNSInteger:(NSInteger)value forObject:(id<YQCloudPropertyObject>)object name:(NSString *)name
{
    NSInteger *ptrValue = [self pointerOfVar:name forObject:object];
    if( ptrValue )
    {
        *ptrValue = value;
    }
    return YES;
}

/** 遍历指定对象的云控属性 */
+ (void)enumCloudPropertyForObject:(id<YQCloudPropertyObject>)object handler:(void(^)(NSString *name, YQCloudPropertyType type))handler
{
    if( !handler || !object )
    {
        return;
    }
    objc_property_t *propertyList = NULL;
    unsigned int nPropertyCount = 0;
    propertyList = class_copyPropertyList([object class], &nPropertyCount);
    NSString *strValueKey = nil;        // 从云控属性取值的key
    for( unsigned int index = 0; index < nPropertyCount; ++index )
    {
        // 遍历属性
        objc_property_t property = *(propertyList + index);
        NSString *strPropertyKey = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        unsigned int nAttribCount = 0;
        objc_property_attribute_t *attribs = property_copyAttributeList(property, &nAttribCount);
        YQCloudPropertyType propertyType = YQCloudPropertyUnknown;
        strValueKey = [[self class] nameOfCloudProperty:strPropertyKey];        // 云控字典中属性的key值
        for( unsigned int index = 0; index < nAttribCount; ++index )
        {
            objc_property_attribute_t attrib = *(attribs + index);
            if( 0 == strcmp(attrib.name, "T") )
            {
                if( 0 == strcmp(attrib.value, "@\"NSNumber<YQCloudFloatProperty>\"") )
                {
                    // 浮点数
                    propertyType = YQCloudPropertyFloat;
                }
                else if( 0 == strcmp(attrib.value, "@\"NSNumber<YQCloudBoolProperty>\"") )
                {
                    // bool值
                    propertyType = YQCloudPropertyBool;
                }
                else if( 0 == strcmp(attrib.value, "@\"NSNumber<YQCloudIntegerProperty>\"") )
                {
                    // 整型数
                    propertyType = YQCloudPropertyInteger;
                }
                else if( 0 == strcmp(attrib.value, "@\"NSString<YQCloudStringProperty>\"") )
                {
                    // 字符串
                    propertyType = YQCloudPropertyString;
                }
                else
                {
                    break;
                }
                handler(strValueKey, propertyType);
                break;
            }
        }
        if( attribs )
        {
            free(attribs);
        }
    }
    if( propertyList )
    {
        free(propertyList);
    }
}

/** 获取成员变量的偏移指针 */
+ (void *)pointerOfVar:(NSString *)name forObject:(id<YQCloudPropertyObject>)object
{
    Ivar var = class_getInstanceVariable([object class], name.UTF8String);
    if( !var )
    {
        return NULL;
    }
    ptrdiff_t offset = ivar_getOffset(var);
    //    const char *szType = ivar_getTypeEncoding(var);
    void *ptr = (__bridge void *)object;
    Byte *ptrB = (Byte *)ptr;
    return ptrB + offset;
}

/** 获取指定对象的云控标识 */
+ (NSString *)cloudIdentifierOfObject:(id<YQCloudPropertyObject>)object
{
    if( !object )
    {
        return nil;
    }
    if( [object respondsToSelector:@selector(cloudPropertyIdentifier)] )
    {
        return [object cloudPropertyIdentifier];
    }
    if( [[object class] respondsToSelector:@selector(cloudPropertyIdentifier)] )
    {
        return [[object class] cloudPropertyIdentifier];
    }
    return NSStringFromClass([object class]);
}


#pragma mark - debug methods

#ifdef  YQCLOUDPROPERTY_DEBUG
/** 获取全部云控类名 */
+ (void)getClassesOfCloudProperty:(void(^)(NSArray <NSString *> *))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        unsigned int nClassCount = 0;
        Class *classes = objc_copyClassList(&nClassCount);
        NSMutableArray <NSString *> *arOutput = [[NSMutableArray alloc] init];
        for( unsigned int i = 0; i < nClassCount; ++i )
        {
            Class cls = *(classes + i);
            if( class_conformsToProtocol(cls, @protocol(YQCloudPropertyObject)) )
            {
                [arOutput addObject:NSStringFromClass(cls)];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if( completion )
            {
                completion(arOutput);
            }
        });
    });
}

/** 增加一个编辑后的云控属性字典 */
- (void)addLocalProperties:(NSDictionary *)propertyDict forIdentifier:(NSString *)identifier
{
    if( !propertyDict )
    {
        [self removeLocalPropertiesForIdentifier:identifier];
        return;
    }
    [_localPropertyDict setObject:propertyDict forKey:identifier];
    [self saveCache];
}

/** 移除一个编辑后的云控属性字典 */
- (void)removeLocalPropertiesForIdentifier:(NSString *)identifier
{
    [_localPropertyDict removeObjectForKey:identifier];
    [self saveCache];
}
#endif  // YQCLOUDPROPERTY_DEBUG

#pragma mark - self operations


/** 根据云控属性值获取成员变量名 */
+ (NSString *)varNameOfCloudProperty:(NSString *)propertyName
{
    NSString *strRet = [self nameOfCloudProperty:propertyName];
    if( !strRet.length )
    {
        return nil;
    }
    return [NSString stringWithFormat:@"_%@", strRet];
}

/** 根据云控属性值获取常规属性名 */
+ (NSString *)nameOfCloudProperty:(NSString *)propertyName
{
    NSString *strRet = propertyName;
    if( [propertyName hasPrefix:@"yqCloud"] )
    {
        strRet = [propertyName substringFromIndex:7];
    }
    return strRet;
}


/** 保存缓存 */
- (void)saveCache
{
    if( !_propertyDict )
    {
        _propertyDict = [[NSMutableDictionary alloc] init];
    }
    NSString *strFile = [[self class] cacheFile];
    [[NSFileManager defaultManager] createDirectoryAtPath:[[self class] cachePath] withIntermediateDirectories:YES attributes:nil error:nil];
    [_propertyDict writeToFile:strFile atomically:YES];
#ifdef YQCLOUDPROPERTY_DEBUG
    strFile = [[self class] localCacheFile];
    [_localPropertyDict writeToFile:strFile atomically:YES];
#endif  // YQCLOUDPROPERTY_DEBUG
}

/** 加载缓存 */
- (void)loadCache
{
    NSString *strFile = [[self class] cacheFile];
    NSDictionary *rootDict = [NSDictionary dictionaryWithContentsOfFile:strFile];
    if( rootDict )
    {
        _propertyDict = [NSMutableDictionary dictionaryWithDictionary:rootDict];
    }
#ifdef YQCLOUDPROPERTY_DEBUG
    strFile = [[self class] localCacheFile];
    rootDict = [NSDictionary dictionaryWithContentsOfFile:strFile];
    if( rootDict )
    {
        _localPropertyDict = [NSMutableDictionary dictionaryWithDictionary:rootDict];
    }
#endif  // YQCLOUDPROPERTY_DEBUG
}

/** 缓存文件路径 */
+ (NSString *)cacheFile
{
    return [[self cachePath] stringByAppendingPathComponent:@"cache.plist"];
}

/** 缓存文件夹 */
+ (NSString *)cachePath
{
    return [NSString stringWithFormat:@"%@/Documents/yqcpm", NSHomeDirectory()];
}

#ifdef YQCLOUDPROPERTY_DEBUG
/** 本地属性编辑缓存文件 */
+ (NSString *)localCacheFile
{
    return [[self cachePath] stringByAppendingPathComponent:@"editedCache.plist"];
}
#endif  // YQCLOUDPROPERTY_DEBUG

@end
