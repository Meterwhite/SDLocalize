//
//  SDLocalize.h
//  Meterwhite
//
//  Created by Meterwhite on 2022/9/1.
//


#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE || TARGET_OS_TV

#import <UIKit/UIKit.h>

#define SDLView         UIView

#elif TARGET_OS_MAC

#import <AppKit/AppKit.h>

#define SDLView         NSView

#endif

NS_ASSUME_NONNULL_BEGIN

#pragma mark - SDLocalize
/// Automatically replaces the text of the control.
///
/// 1. Set the name of the control that you want to localize.
///   view1.sdl_register = @"-"; // Page has no name, xib or code
///   view2.sdl_register = @"LoginPage";// xib or code
///   [view4 sdl_defaultRegister]; // code
/// 2. Perform all registered localization tasks.
///   [SDLocalize defaultLocalize];
///   or
///   [SDLocalize localize:<PageName or NULL> done: ^ {
///     // ...
///   }];
@interface SDLocalize : NSObject

/// [SDLocalize localize:nil done:nil];
+ (void)defaultLocalize;

/// Perform localization tasks.This method is thread-safe.
/// @param pageName Specify a page name to filter other controls.
/// @param done Called after completes.
+ (void)localize:(nullable NSString *)pageName done:(void(^_Nullable)(void))done;

/// Perform the localization task using the specified resource bundle.This method is thread-safe.
/// @param pageName Specify a page name to filter other controls.
/// @param scheme Scheme name.
/// @param done Called after completes.
+ (void)localize:(NSString *)pageName scheme:(nullable NSString *)scheme done:(void (^)(void))done;

/// Use resources from other bundles.
/// The default scheme used in this project: [NSBundle.mainBundle localizedStringForKey:text value:@"" table:nil];
/// @param name A scheme name.
/// @param block How to use resources from other bundles.You need to provide a text localization process.
/// code : { return [YourBundle localizedStringForKey:text value:value table:table] ;}
+ (void)registerScheme:(NSString *)name withBlock:(NSString *(^)(NSString *text))block;

+ (void)removeScheme:(NSString *)name;

/// Specify the text setter and getter for the control. If not specified, the default invocation order is as follows:
/// 1. < UILabe, UIButtonl, UITextView >.text
/// 2. < UITextField >.placeholder
/// 3. Custom getter and setter,
/// 4. Try to call property text and property title
///
/// This information will not be cleared
/// @param getter Specify how to get the text for the specified control.
/// @param setter Specify how to set text to the specified control.
+ (void)customTextGetter:(NSString *(^)(id object))getter andSetter:(void(^)(NSString *localizedText, id object))setter;

/// Clear all localization tasks
+ (void)clean;

#pragma mark - Tools

/// en, ja, fr, ...
+ (NSString *)sdl_systemLanguageKey;

@end

#pragma mark - NSObject(SDLocalize)
@interface NSObject (SDLocalize)

///  This property is used for localized configuration. Set this property to register the localization task.
///  sdl_register is PageName; The symbol '-' means that the Page name is NULL.
///  PS: XIB is supported.
@property (nullable, nonatomic, copy) NSString *sdl_register;

@property (nullable, nonatomic, copy) void(^sdl_localizedDone)(id _Nonnull view);

/// Register the localization task with the default command.
/// Same as the code:
/// [view sdl_register:@"-"];
- (void)sdl_defaultRegister;

/// Specify a control to perform a localization task.
- (void)sdl_localizeIfNeed;

/// Specifies that a control performs a localization task using the specified schema.
/// @param name Scheme name.
- (void)sdl_localizeIfNeedByScheme:(nullable NSString *)name;

#pragma mark - Dynamic format

@property (getter = sdl_isDynamicFormat) BOOL sdl_dynamicFormat;

/// @param args A maximum of 20 parameters are supported
- (void)sdl_localizeWithFormateArgs:(NSArray *)args;

/// A maximum of 20 parameters are supported
@property (nullable, nonatomic, copy) NSArray *sdl_formatArgs;

@end

#pragma mark - Xcode suportted

@interface SDLView (SDLocalize)

@property (nullable, nonatomic, copy) IBInspectable NSString *sdl_register;

@property (nullable, nonatomic, copy) void(^sdl_localizedDone)(id _Nonnull view);

@property (getter = sdl_isDynamicFormat) IBInspectable BOOL sdl_dynamicFormat;

@end

#pragma mark - NSString (SDLocalize)

@interface NSString (SDLocalize)

- (NSString *)sdl_localizedString;

- (NSString *)sdl_localizedStringWithScheme:(nullable NSString *)name;

@end

#pragma mark - NSArray (SDLocalize)

@interface NSArray (SDLocalize)

- (NSArray *)sdl_localizedArray;

- (NSArray *)sdl_localizedArrayWithScheme:(nullable NSString *)name;

@end


NS_ASSUME_NONNULL_END
