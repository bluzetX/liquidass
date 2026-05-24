#import "../Shared/LGSharedSupport.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat sControlCenterSmallModuleCornerRadius = 0.0;

static BOOL LGControlCenterEnabled(void) {
    return LG_globalEnabled() && LG_prefBool(@"ControlCenter.Enabled", YES);
}

static BOOL LGControlCenterClassNameEquals(UIView *view, NSString *className) {
    return view && [NSStringFromClass(view.class) isEqualToString:className];
}

static void LGControlCenterApplyCornerRadius(UIView *view, CGFloat cornerRadius) {
    if (!view || cornerRadius <= 0.0) return;
    view.clipsToBounds = YES;
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = cornerRadius;
    if (@available(iOS 13.0, *)) {
        view.layer.cornerCurve = kCACornerCurveCircular;
    }
}

static BOOL LGControlCenterIsModuleCandidate(UIView *moduleView) {
    CGSize size = moduleView.bounds.size;
    CGFloat minSide = fmin(size.width, size.height);
    CGFloat maxSide = fmax(size.width, size.height);
    if (minSide < 20.0) return NO;
    return maxSide <= minSide * 1.25;
}

static CGFloat LGControlCenterModuleCornerRadius(UIView *moduleView) {
    CGFloat moduleHeight = CGRectGetHeight(moduleView.bounds);
    if (moduleHeight <= 0.0) return 0.0;

    CGFloat measuredRadius = moduleHeight * 0.5;
    if (moduleHeight < 100.0) {
        sControlCenterSmallModuleCornerRadius = measuredRadius;
        return measuredRadius;
    }
    return sControlCenterSmallModuleCornerRadius > 0.0 ? sControlCenterSmallModuleCornerRadius : measuredRadius;
}

static void LGControlCenterCirclifyModuleView(UIView *moduleView) {
    if (!LGControlCenterEnabled()) return;
    if (!LGControlCenterClassNameEquals(moduleView, @"CCUIContentModuleContainerView")) return;
    if (!LGControlCenterIsModuleCandidate(moduleView)) return;

    UIView *contentContainer = nil;
    for (UIView *sub in moduleView.subviews) {
        if (LGControlCenterClassNameEquals(sub, @"CCUIContentModuleContentContainer") ||
            LGControlCenterClassNameEquals(sub, @"CCUIContentModuleContentContainerView")) {
            contentContainer = sub;
            break;
        }
    }

    CGFloat cornerRadius = LGControlCenterModuleCornerRadius(moduleView);
    LGControlCenterApplyCornerRadius(moduleView, cornerRadius);
    if (contentContainer) LGControlCenterApplyCornerRadius(contentContainer, cornerRadius);
}

static void LGControlCenterCirclifySquareModuleMaterialView(UIView *materialView) {
    if (!LGControlCenterEnabled()) return;
    if (!LGControlCenterClassNameEquals(materialView, @"MTMaterialView")) return;

    UIView *parent = materialView.superview;
    if (!LGControlCenterClassNameEquals(parent, @"CCUIContentModuleContentContainer") &&
        !LGControlCenterClassNameEquals(parent, @"CCUIContentModuleContentContainerView")) return;

    UIView *moduleView = nil;
    UIView *ancestor = parent.superview;
    while (ancestor) {
        if (LGControlCenterClassNameEquals(ancestor, @"CCUIContentModuleContainerView")) {
            moduleView = ancestor;
            break;
        }
        ancestor = ancestor.superview;
    }
    if (!moduleView || !LGControlCenterIsModuleCandidate(moduleView)) return;

    LGControlCenterApplyCornerRadius(materialView, LGControlCenterModuleCornerRadius(moduleView));
}

static void LGControlCenterCirclifyMediaPlayerMaterialView(UIView *materialView) {
    if (!LGControlCenterEnabled()) return;
    if (!LGControlCenterClassNameEquals(materialView, @"MTMaterialView")) return;

    UIView *uiViewParent = materialView.superview;
    if (!LGControlCenterClassNameEquals(uiViewParent, @"UIView")) return;

    UIView *mruView = uiViewParent.superview;
    if (!LGControlCenterClassNameEquals(mruView, @"MRUControlCenterView")) return;

    UIView *contentContainer = mruView.superview;
    if (!LGControlCenterClassNameEquals(contentContainer, @"CCUIContentModuleContentContainer") &&
        !LGControlCenterClassNameEquals(contentContainer, @"CCUIContentModuleContentContainerView")) return;

    UIView *moduleView = nil;
    UIView *ancestor = contentContainer.superview;
    while (ancestor) {
        if (LGControlCenterClassNameEquals(ancestor, @"CCUIContentModuleContainerView")) {
            moduleView = ancestor;
            break;
        }
        ancestor = ancestor.superview;
    }
    if (!moduleView || !LGControlCenterIsModuleCandidate(moduleView)) return;

    LGControlCenterApplyCornerRadius(materialView, LGControlCenterModuleCornerRadius(moduleView));
}

static void LGControlCenterCirclify1x2MaterialView(UIView *materialView) {
    if (!LGControlCenterEnabled()) return;
    if (!LGControlCenterClassNameEquals(materialView, @"MTMaterialView")) return;

    UIView *parent = materialView.superview;
    if (!LGControlCenterClassNameEquals(parent, @"CCUIContentModuleContentContainer") &&
        !LGControlCenterClassNameEquals(parent, @"CCUIContentModuleContentContainerView")) return;

    CGFloat width = CGRectGetWidth(materialView.bounds);
    CGFloat height = CGRectGetHeight(materialView.bounds);
    if (width <= 100.0 || height >= 100.0) return;

    BOOL hasUIViewSibling = NO;
    for (UIView *sibling in parent.subviews) {
        if (sibling != materialView && LGControlCenterClassNameEquals(sibling, @"UIView")) {
            hasUIViewSibling = YES;
            break;
        }
    }
    if (!hasUIViewSibling) return;

    LGControlCenterApplyCornerRadius(materialView, height * 0.5);
}

static void LGControlCenterCirclifyFocusMaterialView(UIView *materialView) {
    if (!LGControlCenterEnabled()) return;
    if (!LGControlCenterClassNameEquals(materialView, @"MTMaterialView")) return;

    UIView *parent = materialView.superview;
    if (!LGControlCenterClassNameEquals(parent, @"UIView")) return;
    if (!LGControlCenterClassNameEquals(parent.superview, @"UIView")) return;
    if (!LGControlCenterClassNameEquals(parent.superview.superview, @"CCUIContentModuleContentContainerView")) return;

    CGFloat width = CGRectGetWidth(materialView.bounds);
    CGFloat height = CGRectGetHeight(materialView.bounds);
    if (width <= 100.0 || height >= 100.0) return;

    BOOL hasUIViewSibling = NO;
    for (UIView *sibling in parent.subviews) {
        if (sibling != materialView && LGControlCenterClassNameEquals(sibling, @"UIView")) {
            hasUIViewSibling = YES;
            break;
        }
    }
    if (!hasUIViewSibling) return;

    LGControlCenterApplyCornerRadius(materialView, height * 0.5);
}

static void LGControlCenterCirclifyToggleFillView(UIView *buttonModuleView) {
    if (!LGControlCenterEnabled()) return;
    if (!LGControlCenterClassNameEquals(buttonModuleView, @"CCUIButtonModuleView")) return;

    UIView *moduleView = nil;
    UIView *ancestor = buttonModuleView.superview;
    while (ancestor) {
        if (LGControlCenterClassNameEquals(ancestor, @"CCUIContentModuleContainerView")) {
            moduleView = ancestor;
            break;
        }
        ancestor = ancestor.superview;
    }
    if (!moduleView || !LGControlCenterIsModuleCandidate(moduleView)) return;

    CGFloat cornerRadius = LGControlCenterModuleCornerRadius(moduleView);
    for (UIView *child in buttonModuleView.subviews) {
        if (LGControlCenterClassNameEquals(child, @"UIView")) {
            LGControlCenterApplyCornerRadius(child, cornerRadius);
        }
    }
}

static void LGControlCenterApplySliderSiblingMaterialRadius(UIView *sliderView) {
    UIView *parent = sliderView.superview;
    if (!parent) return;
    if (!LGControlCenterClassNameEquals(parent, @"CCUIContentModuleContentContainer") &&
        !LGControlCenterClassNameEquals(parent, @"CCUIContentModuleContentContainerView")) return;

    for (UIView *sibling in parent.subviews) {
        if (sibling == sliderView) continue;
        if (LGControlCenterClassNameEquals(sibling, @"MTMaterialView")) {
            LGControlCenterApplyCornerRadius(sibling, CGRectGetWidth(sibling.bounds) * 0.5);
        }
    }
}

static void LGControlCenterApplySliderFillRadius(UIView *sliderView) {
    for (UIView *child in sliderView.subviews) {
        if (!LGControlCenterClassNameEquals(child, @"UIView")) continue;
        for (UIView *grandchild in child.subviews) {
            if (LGControlCenterClassNameEquals(grandchild, @"MTMaterialView")) {
                LGControlCenterApplyCornerRadius(grandchild, CGRectGetWidth(grandchild.bounds) * 0.5);
            }
        }
    }
}

static void LGControlCenterApplySliderViewRadii(UIView *sliderView) {
    if (!LGControlCenterEnabled()) return;
    if (!LGControlCenterClassNameEquals(sliderView, @"CCUIContinuousSliderView")) return;

    LGControlCenterApplySliderSiblingMaterialRadius(sliderView);
    LGControlCenterApplySliderFillRadius(sliderView);
}

static void LGControlCenterApplyMRUSliderViewRadii(UIView *sliderView) {
    if (!LGControlCenterEnabled()) return;
    if (!LGControlCenterClassNameEquals(sliderView, @"MRUContinuousSliderView")) return;

    for (UIView *child in sliderView.subviews) {
        if (LGControlCenterClassNameEquals(child, @"MTMaterialView")) {
            LGControlCenterApplyCornerRadius(child, CGRectGetWidth(child.bounds) * 0.5);
        } else if (LGControlCenterClassNameEquals(child, @"UIView")) {
            for (UIView *grandchild in child.subviews) {
                if (LGControlCenterClassNameEquals(grandchild, @"MTMaterialView")) {
                    LGControlCenterApplyCornerRadius(grandchild, CGRectGetWidth(grandchild.bounds) * 0.5);
                }
            }
        }
    }
}

static void LGControlCenterRoundContentContainerMaterialViews(UIView *contentContainer) {
    if (!LGControlCenterEnabled()) return;
    if (!LGControlCenterClassNameEquals(contentContainer, @"CCUIContentModuleContentContainer") &&
        !LGControlCenterClassNameEquals(contentContainer, @"CCUIContentModuleContentContainerView")) return;

    @try {
        BOOL expanded = [contentContainer valueForKey:@"_expanded"] != nil &&
                        [[contentContainer valueForKey:@"_expanded"] boolValue];
        if (expanded) return;
    } @catch (NSException *e) {}

    UIView *moduleView = nil;
    UIView *ancestor = contentContainer.superview;
    while (ancestor) {
        if (LGControlCenterClassNameEquals(ancestor, @"CCUIContentModuleContainerView")) {
            moduleView = ancestor;
            break;
        }
        ancestor = ancestor.superview;
    }

    NSMutableArray *stack = [NSMutableArray arrayWithArray:contentContainer.subviews];
    while (stack.count > 0) {
        UIView *view = stack.lastObject;
        [stack removeLastObject];

        if (LGControlCenterClassNameEquals(view, @"MTMaterialView")) {
            CGFloat width = CGRectGetWidth(view.bounds);
            CGFloat height = CGRectGetHeight(view.bounds);

            if (moduleView && LGControlCenterIsModuleCandidate(moduleView)) {
                LGControlCenterApplyCornerRadius(view, LGControlCenterModuleCornerRadius(moduleView));
            } else if (width > 100.0 && height < 100.0) {
                LGControlCenterApplyCornerRadius(view, height * 0.5);
            } else {
                LGControlCenterApplyCornerRadius(view, width * 0.5);
            }
        }

        [stack addObjectsFromArray:view.subviews];
    }
}

%group LGControlCenterSpringBoard

%hook CCUIContentModuleContainerView

- (void)willMoveToWindow:(UIWindow *)newWindow {
    LGControlCenterCirclifyModuleView((UIView *)self);
    %orig;
    LGControlCenterCirclifyModuleView((UIView *)self);
}

- (void)didMoveToWindow {
    %orig;
    LGControlCenterCirclifyModuleView((UIView *)self);
}

- (void)layoutSubviews {
    %orig;
    LGControlCenterCirclifyModuleView((UIView *)self);
}

%end

%hook CCUIContentModuleContentContainerView

- (void)layoutSubviews {
    %orig;
    LGControlCenterRoundContentContainerMaterialViews((UIView *)self);
}

%end

%hook MTMaterialView

- (void)willMoveToSuperview:(UIView *)newSuperview {
    LGControlCenterCirclifySquareModuleMaterialView((UIView *)self);
    LGControlCenterCirclifyMediaPlayerMaterialView((UIView *)self);
    LGControlCenterCirclify1x2MaterialView((UIView *)self);
    LGControlCenterCirclifyFocusMaterialView((UIView *)self);
    %orig;
    LGControlCenterCirclifySquareModuleMaterialView((UIView *)self);
    LGControlCenterCirclifyMediaPlayerMaterialView((UIView *)self);
    LGControlCenterCirclify1x2MaterialView((UIView *)self);
    LGControlCenterCirclifyFocusMaterialView((UIView *)self);
}

- (void)didMoveToSuperview {
    %orig;
    LGControlCenterCirclifySquareModuleMaterialView((UIView *)self);
    LGControlCenterCirclifyMediaPlayerMaterialView((UIView *)self);
    LGControlCenterCirclify1x2MaterialView((UIView *)self);
    LGControlCenterCirclifyFocusMaterialView((UIView *)self);
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    LGControlCenterCirclifySquareModuleMaterialView((UIView *)self);
    LGControlCenterCirclifyMediaPlayerMaterialView((UIView *)self);
    LGControlCenterCirclify1x2MaterialView((UIView *)self);
    LGControlCenterCirclifyFocusMaterialView((UIView *)self);
    %orig;
    LGControlCenterCirclifySquareModuleMaterialView((UIView *)self);
    LGControlCenterCirclifyMediaPlayerMaterialView((UIView *)self);
    LGControlCenterCirclify1x2MaterialView((UIView *)self);
    LGControlCenterCirclifyFocusMaterialView((UIView *)self);
}

- (void)didMoveToWindow {
    %orig;
    LGControlCenterCirclifySquareModuleMaterialView((UIView *)self);
    LGControlCenterCirclifyMediaPlayerMaterialView((UIView *)self);
    LGControlCenterCirclify1x2MaterialView((UIView *)self);
    LGControlCenterCirclifyFocusMaterialView((UIView *)self);
}

- (void)layoutSubviews {
    %orig;
    LGControlCenterCirclifySquareModuleMaterialView((UIView *)self);
    LGControlCenterCirclifyMediaPlayerMaterialView((UIView *)self);
    LGControlCenterCirclify1x2MaterialView((UIView *)self);
    LGControlCenterCirclifyFocusMaterialView((UIView *)self);
}

%end

%hook CCUIButtonModuleView

- (void)willMoveToWindow:(UIWindow *)newWindow {
    %orig;
    LGControlCenterCirclifyToggleFillView((UIView *)self);
}

- (void)didMoveToWindow {
    %orig;
    LGControlCenterCirclifyToggleFillView((UIView *)self);
}

- (void)layoutSubviews {
    %orig;
    LGControlCenterCirclifyToggleFillView((UIView *)self);
}

%end

%hook CCUIContinuousSliderView

- (void)willMoveToWindow:(UIWindow *)newWindow {
    %orig;
    LGControlCenterApplySliderViewRadii((UIView *)self);
}

- (void)didMoveToWindow {
    %orig;
    LGControlCenterApplySliderViewRadii((UIView *)self);
}

- (void)layoutSubviews {
    %orig;
    LGControlCenterApplySliderViewRadii((UIView *)self);
}

%end

%hook MRUContinuousSliderView

- (void)willMoveToWindow:(UIWindow *)newWindow {
    %orig;
    LGControlCenterApplyMRUSliderViewRadii((UIView *)self);
}

- (void)didMoveToWindow {
    %orig;
    LGControlCenterApplyMRUSliderViewRadii((UIView *)self);
}

- (void)layoutSubviews {
    %orig;
    LGControlCenterApplyMRUSliderViewRadii((UIView *)self);
}

%end

%end

%ctor {
    if (!LGIsSpringBoardProcess()) return;
    %init(LGControlCenterSpringBoard);
}
