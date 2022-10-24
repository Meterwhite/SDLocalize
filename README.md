# SDLocalize
> [修改Cocoapods源代码!](https://github.com/Meterwhite/ObjcHook4pod)
## 介绍 Introduce
* Efficient iOS localization solution.(Objc, swift, NSLocalizedString, xib)
* 高效的iOS本地化解决方案
* 点赞富一生.
* Good luck for one start .

## Import
- Drag floder `SDLocalize` to your project.
```objc
#import "SDLocalize.h"
```
## CocoaPods
```
pod 'SDLocalize'
```

## 工作原理
1. 首先标记一组需要本地化的控件
2. 然后在恰当时机(viewDidLoad),触发一组本地化任务
3. 
```objc

```
## 分步处理复杂的业务 Step-by-step processing of complex business.
```objc
SDMask<UserView*>* mask = SDAlertMaskWith(currentController, userView);
[mask userViewDidLoad:^(SDMaskModel<UserView*> * model) {
    model.
    setAutolayoutValueForKey(@(0),   @"bottom").
    setAutolayoutValueForKey(@(15),  @"left").
    setAutolayoutValueForKey(@(15),  @"right").
    setAutolayoutValueForKey(@(350), @"height");
}];
[mask bindEventForControls:@[Button1, Button2, [Button3 sdm_withBindingKey:@"MyKey"], ...]];
[mask bindEventForCancelControl:CancelButton];
[mask bindingEventFor:Button1 usingBlock:^(SDMaskBindingEvent<UserView*> * event) {
    /// ...
}];
[mask bindingEventFor:@"MyKey" usingBlock:^(SDMaskBindingEvent<UserView*> * event) {
    /// ...
}];
[mask show];
```
## 引导控制器 SDMaskGuidController
### 在一个XIB文件中设置多个页面的约束进行适配，可以适应90%的设计需求。Set multiple guid pages in one controller XIB file ! By changing the constraints in XIB to adapt the device, this solution can address 90% of the design needs.
```objc
[[[MySDMaskGuidController new] userViewDidLoad:^(SDMaskModel * _Nonnull model) {
    /// Set the same color as user view to background.
    [model setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.6]];
}] show];
```
## 链式编程 Chain programming
-  链式编程涵盖了大多数方法 Chained programming covers most methods
```objc
[...[[[mask bindEventForControls:@[okButton]] bindEventForCancelControl:cancelButton] bindingEventsUsingBlock:^(SDMaskBindingEvent<UserView*>* event) {
    
}]... show];
```
## Use autolayout
### 自动布局的两种方式 Tow ways to use autolayout.
- a. 框架提供 Use the methods provided by the SDMask to use autolayout. 
```objc
[mask userViewDidLoad:^(SDMaskModel<UserView*> * model) {
    model.
    setAutolayoutValueForKey(@(0), @"bottom").
    setAutolayoutValueForKey(@(15), @"left").
    setAutolayoutValueForKey(@(15), @"right").
    setAutolayoutValueForKey(@(350), @"height");
}];
```
- b. 三方或手动布局 Autolayout by youself. Like 'masonry'
```objc
[mask userViewDidLoad:^(SDMaskModel<UserView*> * model) {
    [model.userView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(model.containerView);
        make.left.equalTo(model.containerView.mas_left).offset(20);
        make.right.equalTo(model.containerView.mas_right).offset(-20);
    }];
}];
```
## 自定义动画 Use custom animations
- Framelayout
```objc
[[[[[mask userViewPresentationWillAnimate:^(SDMaskModel<UserView*> * model) {
    userView.frame = frameA;
}] userViewPresentationDoAnimations:^(SDMaskModel<UserView*> * model) {
    userView.frame = frameB;
}] userViewDismissionWillAnimate:^(SDMaskModel<UserView*> * model) {
    /// ...
}] userViewDismissionDoAnimations:^(SDMaskModel<UserView*> * model) {
    userView.frame = frameA;
}] disableSystemAnimation];
```
- Autolayout
```objc
[[[[[mask userViewPresentationWillAnimate:^(SDMaskModel<UserView*> * model) {
    userView.bottonConstraint = A;
    //[self.view setNeedsLayout];
    //[self.view layoutIfNeeded];
}] userViewPresentationDoAnimations:^(SDMaskModel<UserView*> * model) {
    userView.bottonConstraint = B;
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}] userViewDismissionWillAnimate:^(SDMaskModel<UserView*> * model) {
    /// ...
}] userViewDismissionDoAnimations:^(SDMaskModel<UserView*> * model) {
    userView.bottonConstraint = A;
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}] disableSystemAnimation];
```
## 使用泛型 Use generics
* 泛型宏定义的使用可以避免在外部声明弱引用 The use of macro definitions for generic functions can avoid declaring weak references externally  

## Email
- app合作：meterwhite@outlook.com
