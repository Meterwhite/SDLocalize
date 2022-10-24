//
//  SDLocalize.m
//  Meterwhite
//
//  Created by Meterwhite on 2022/9/1.
//

#import "SDLocalize.h"

static NSLock *_lock_cmd_map;

static NSMapTable<NSObject *, NSString*> *_map_obj_registerValue;

static NSMapTable<NSObject *, NSString*> *_map_obj_dynamicFormat;

static NSMapTable<NSObject *, NSArray*> *_map_obj_args;

static NSMapTable<NSObject *, id> *_map_obj_done;

static NSMapTable<NSString *, id> *_map_scheme_block;

static NSString *(^_customGetter)(id view);

static void(^_customSetter)(NSString *, id view);

NSString *getLocalizedText(NSString *text, NSString *scheme)  {
    if(scheme != nil) {
        NSString *(^block)(NSString *) = [_map_scheme_block objectForKey:scheme];
        if (block != nil) {
            return block(text);
        } else {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"The Scheme does not exist." userInfo:nil];
        }
    }
    return [NSBundle.mainBundle localizedStringForKey:text value:@"" table:nil];
}

NSString *stringFormatWithArray(NSString *format, NSArray *arguments) {
    size_t size = sizeof(NSString *) * arguments.count;
    char *argList = malloc(size);
    [arguments getObjects:(__unsafe_unretained id *)(void *)argList range:(NSMakeRange(0, arguments.count))];
    NSString* result = [[NSString alloc] initWithFormat:format arguments:(void *)argList];
    free(argList);
    return result;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
NSString * getControlText(id view)  {
    if([view sdl_isDynamicFormat]) {
        return [_map_obj_dynamicFormat objectForKey:view];
    }
    NSString *text;
#if TARGET_OS_IPHONE || TARGET_OS_TV
    if ([view isKindOfClass:UILabel.class]) {
        UILabel *_view = (id)view;
        text = [_view text];
    } else if ([view isKindOfClass:UIButton.class]) {
        UIButton *_view = (id)view;
        text = [_view titleForState:UIControlStateNormal];
    } else if ([view isKindOfClass:UITextView.class]) {
        UITextView *_view = (id)view;
        text = [_view text];
    } else if ([view isKindOfClass:UITextField.class]) {
        UITextField *_view = (id)view;
        text = [_view placeholder];
    } else
#endif
        if(_customGetter != nil && _customSetter != nil) {
            text = _customGetter(view);
        } else if ([view respondsToSelector:@selector(text)] && [view respondsToSelector:@selector(setText:)]) {
            text = [view performSelector:@selector(text)];
        } else if ([view respondsToSelector:@selector(title)] && [view respondsToSelector:@selector(setTitle:)]) {
            text = [view performSelector:@selector(title)];
        }
    return text;
}
#pragma clang diagnostic pop

#pragma mark - SDLocalize

@interface SDLocalize()

@end

@implementation SDLocalize

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _map_obj_registerValue = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsCopyIn];
        _map_obj_done = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsCopyIn];
        _map_obj_dynamicFormat = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsCopyIn];
        _map_obj_args = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsCopyIn];
        _map_scheme_block = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsObjectPersonality | NSPointerFunctionsCopyIn) valueOptions:NSPointerFunctionsObjectPersonality | NSPointerFunctionsCopyIn];
        _lock_cmd_map = [NSLock new];
    });
}

+ (void)registerScheme:(NSString *)name withBlock:(NSString * _Nonnull (^)(NSString * _Nonnull))block {
    if (![name isKindOfClass:[NSString class]]) {
        return;
    }
    [_map_scheme_block setObject:block forKey:name];
}

+ (void)removeScheme:(NSString *)name {
    [_map_scheme_block removeObjectForKey:name];
}

+ (void)defaultLocalize {
    [self localize:nil done:nil];
}

+ (void)localize:(NSString *)pageName done:(void (^)(void))done {
    [self localize:pageName scheme:nil done:done];
}

+ (void)localize:(NSString *)pageName scheme:(NSString *)scheme done:(void (^)(void))done {
    if (_map_obj_registerValue.count == 0) {
        return;
    }
    [_lock_cmd_map lock];
    NSMutableSet *unregisterViews = [NSMutableSet set];
    [_map_obj_registerValue.keyEnumerator.allObjects enumerateObjectsUsingBlock:^(NSObject * _Nonnull object, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *regValue = [_map_obj_registerValue objectForKey:object];
        if ([regValue length] == 0) {
            return;
        }
        if (pageName != nil && ![pageName isEqualToString:regValue] && ![regValue isEqualToString:@"-"]) {
            return;
        }
        [SDLocalize localizeObject:object withScheme:scheme];
        void(^localizedDone)(id view) = [_map_obj_done objectForKey:object];
        if (localizedDone) {
            localizedDone(object);
        }
        if (![object sdl_isDynamicFormat]) {
            [unregisterViews addObject:object];
        }
    }];
    [unregisterViews enumerateObjectsUsingBlock:^(SDLView * _Nonnull view, BOOL * _Nonnull stop) {
        [_map_obj_registerValue removeObjectForKey:view];
        [_map_obj_done removeObjectForKey:view];
    }];
    [_lock_cmd_map unlock];
    if(done) done();
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
+ (void)localizeObject:(id)object withScheme:(NSString *)scheme {
    NSString *text;
    text = getLocalizedText(getControlText(object), scheme);
    if (text == nil) {
        return;
    }
    if([object sdl_isDynamicFormat]) {
        NSArray *args = [_map_obj_args objectForKey:object];
        if(args) {
            text = stringFormatWithArray(text, args);            
        }
    }
#if TARGET_OS_IPHONE || TARGET_OS_TV
    if ([object isKindOfClass:UILabel.class]) {
        [(UILabel *)object setText:text];
    } else if ([object isKindOfClass:UIButton.class]) {
        [(UIButton *)object setTitle:text forState:UIControlStateNormal];
    } else if ([object isKindOfClass:UITextView.class]) {
        [(UITextView *)object setText:text];
    } else if ([object isKindOfClass:UITextField.class]) {
        [(UITextField *)object setPlaceholder:text];
    } else
#endif
        if(_customGetter != nil && _customSetter != nil) {
            _customSetter(text, object);
        } else if ([object respondsToSelector:@selector(text)] && [object respondsToSelector:@selector(setText:)]) {
            [object performSelector:@selector(setText:) withObject:text];
        } else if ([object respondsToSelector:@selector(titleLb)] && [object respondsToSelector:@selector(setTitleLb:)]) {
            [object performSelector:@selector(setTitleLb:) withObject:text];
        }
}
#pragma clang diagnostic pop

+ (void)customTextGetter:(NSString * _Nonnull (^)(id _Nonnull))getter andSetter:(void (^)(NSString * _Nonnull, id _Nonnull))setter {
    _customGetter = [getter copy];
    _customSetter = [setter copy];
}

+ (void)clean {
    [_lock_cmd_map lock];
    [_map_obj_registerValue removeAllObjects];
    [_map_obj_done removeAllObjects];
    [_map_scheme_block removeAllObjects];
    [_lock_cmd_map unlock];
}

+ (NSString *)sdl_systemLanguageKey {
    NSString *language = [[NSLocale autoupdatingCurrentLocale] localeIdentifier];
    NSArray *items = [language componentsSeparatedByString:@"_"];
    return items.firstObject;
}

@end

#pragma mark - NSObject(SDLocalize)

@implementation NSObject(SDLocalize)

- (NSString *)sdl_register {
    NSString *rt = [_map_obj_registerValue objectForKey:self];
    return rt;
}

- (void)setSdl_register:(NSString *)cmd {
    [_lock_cmd_map lock];
    [_map_obj_registerValue setObject:cmd forKey:self];
    [_lock_cmd_map unlock];
}

- (BOOL)sdl_isDynamicFormat {
    return [_map_obj_dynamicFormat objectForKey:self] != nil;
}

- (void)setSdl_dynamicFormat:(BOOL)dynamicFormat {
    if(dynamicFormat) {
        id text = getControlText(self);
        [_map_obj_dynamicFormat setObject:text forKey:self];
    } else {
        [_map_obj_dynamicFormat removeObjectForKey:self];
    }
}

- (NSArray *)sdl_formatArgs {
    return [_map_obj_args objectForKey:self];
}

- (void)setSdl_formatArgs:(NSArray *)formatArgs {
    [_map_obj_args setObject:formatArgs forKey:self];
}

- (void)sdl_defaultRegister {
    [self setSdl_register:@"-"];
}

- (void (^)(id _Nonnull))sdl_localizedDone {
    return [_map_obj_done objectForKey:self];
}

- (void)setSdl_localizedDone:(void (^)(id _Nonnull))sd_localizedDone {
    [_map_obj_done setObject:sd_localizedDone forKey:self];
}

- (void)sdl_localizeIfNeed {
    [self sdl_localizeIfNeedByScheme:nil];
}

- (void)sdl_localizeIfNeedByScheme:(NSString *)name {
    [_lock_cmd_map lock];
    [SDLocalize localizeObject:self withScheme:name];
    void(^localizedDone)(id view) = [_map_obj_done objectForKey:self];
    if (localizedDone) {
        localizedDone(self);
        [_map_obj_done removeObjectForKey:self];
    }
    [_map_obj_registerValue removeObjectForKey:self];
    [_lock_cmd_map unlock];
}

- (void)sdl_localizeWithFormateArgs:(NSArray *)args {
    self.sdl_formatArgs = args;
    [self sdl_localizeIfNeed];
}

@end

#pragma mark - NSString (SDLocalize)

@implementation NSString (SDLocalize)

- (NSString *)sdl_localizedString {
    return [self sdl_localizedStringWithScheme:nil];
}

- (NSString *)sdl_localizedStringWithScheme:(NSString *)schemeName {
    return getLocalizedText(self, schemeName);
}

@end

@implementation NSArray (SDLocalize)

- (NSArray *)sdl_localizedArray {
    return [self sdl_localizedArrayWithScheme:nil];
}

- (NSArray *)sdl_localizedArrayWithScheme:(NSString *)name {
    NSMutableArray *rt = [NSMutableArray array];
    for (id item in self) {
        if([item isKindOfClass:[NSString class]]) {
            [rt addObject:[item sdl_localizedStringWithScheme:name]];
        } else if([item isKindOfClass:[NSArray class]]) {
            [rt addObject:[item sdl_localizedArrayWithScheme:name]];
        } else {
            [item sdl_localizeIfNeedByScheme:name];
            [rt addObject:item];
        }
    }
    return [rt copy];
}

@end
