# SDLocalize
> [修改Cocoapods源代码!](https://github.com/Meterwhite/ObjcHook4pod)
## 介绍 Introduce
* Efficient iOS localization solution.(Objc, swift, NSLocalizedString, xib)
* 高效的iOS本地化解决方案
* 点赞富一生.

## 导入(Import)
- Drag floder `SDLocalize` to your project.
```objc
#import "SDLocalize.h"
```
## CocoaPods
```
pod 'SDLocalize'
```

## 对象列表(The object list)
- SDLocalize
- NSObject + SDLocalize
- NSString + SDLocalize
- NSArray + SDLocalize

## SDLocalize工作原理(How SDLocalize works)
1. 首先标记一组需要本地化的控件
2. 然后在恰当时机(viewDidLoad),触发一组本地化任务(Then (viewDidLoad) fires a set of localization tasks when needed)
3. SDLocalize会使用控件的文本作为LocalizedString.key替换当前控件的文本
> 1. Start by marking a set of controls that need to be localized
> 2. Then (viewDidLoad) fires a set of localization tasks when needed
> 3. SDLocalize replaces the text of the current control with the text of the control as LocalizedString.key

## 在XIB上使用(Use on the XIB)
- 设置pageName至sdl_register
```objc
// It then triggers a set of localization tasks when needed
- (void)viewDidLoad {
    [SDLocalize defaultLocalize];
}
```
## 使用代码创建控件并完成本地化(Use code to create and localize the control)
```objc
control0.text = <LocalizedString.key>;
control1.text = <LocalizedString.key>;
control2.text = <LocalizedString.key>;
...
[control0 sdl_defaultRegister];
[control1 sdl_defaultRegister];
[control2 sdl_defaultRegister];
...
// 然后在恰当时机(viewDidLoad),触发一组本地化任务
// It then triggers a set of localization tasks when needed
- (void)viewDidLoad {
    [SDLocalize defaultLocalize]; // Takes effect on all controls marked as default pages
    //[control0 sdl_localizeIfNeed];
    //[control1 sdl_localizeIfNeed];
    //[control2 sdl_localizeIfNeed];
    // ...
}
```
## 默认支持的控件(Supported controls)
- `< UILabe, UIButtonl, UITextView >.text`
- `< UITextField >.placeholder`
## 支持的自定义控件(Supported custom controls)
```objc
[SDLocalize customTextGetter:^(id object){
    if(object is MyView) {
        return myView.myText;
    }
} andSetter:^(NSString *localizedText, id object){
    if(object is MyView) {
        myView.myText = localizedText;
    }
}];
```

## 动态格式文本(Dynamic format text)
```objc
control.sdl_dynamicFormat = @"My name is %@, %@ years old."; // XIB supported
...
[control sdl_localizeWithFormateArgs:@[name, age]];
```

## 手动本地化(Perform localization manually)
```objc
[control sdl_localizeIfNeed];
```

## 扩展(Category)
```objc
string.sdl_localizedString;
@[string0, string1, string2, ...].sdl_localizedArray;
```

## 回调(Callback)
```objc
control.sdl_localizedDone
```

## 更多(More)
- 阅读源代码(Read the source code)

## Email
- app合作：meterwhite@outlook.com
