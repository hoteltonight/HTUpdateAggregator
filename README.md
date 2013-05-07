HTUpdateAggregator
==================

#### HTUpdateAggregator improves update logic in NSObject/UIView/UIViewController subclasses

* Familiar pattern of __updateContent, setNeedsUpdate, and updateIfNeeded__ 
  * Just like layoutSubviews, setNeedsLayout, and layoutIfNeeded
* Automatically trigger updates using key-value observation of properties
  * Avoids overriding setters, potentially breaking synthesized behaviors and adding boilerplate 
* Aggregate update calls within runloops
* Centralized updateContent improves maintainability for most cases

## Example

Implement updateContent:
```
- (void)updateContent
{
    self.makeLabel.text = self.make;
    self.modelLabel.text = self.model;
    self.colorNameLabel.text = self.colorName;
    self.descriptionLabel.text = self.carDescription;
    [self setNeedsLayout];
}
```

Implement keyPathsTriggerUpdate:
```objc
+ (NSArray *)keyPathsToTriggerUpdate
{
    return @[@"make", @"colorName", @"model", @"carDescription"];
}
```

__That's it.__  When one of the keypaths changes, setNeedsUpdate is automatically called.

If you are not a UIView or UIViewController, __you must call startObservingForUpdates on yourself to add the observers during initialization.__ 


## Demo

See demo in https://github.com/hoteltonight/HTKit

HTCarDetailsViewV1, V2 and V3 show incremental improvements to a simple dynamic UI component using these tools.

This sequence of improvements was discussed at [NSMeetup April 2013](http://www.meetup.com/nsmeetup/events/109741812/?action=detail&eventId=109741812), slides here: http://d.pr/f/jczG

## Installation

The recommended installation method is cocoapods. Add this line to your Podfile:

    pod 'HTGraphics'

http://cocoapods.org

SFObservers is a dependency for those who don't cocoapods.

## Discussion

SFObservers is a dependecy, used to automatically remove KVO observers.  

## Contributions welcome!

## Use it? Love/hate it?

Tweet the authors @jakejennings and @jonsibs, and check out HotelTonight's engineering blog: http://engineering.hoteltonight.com

Also, check out HotelTonight's other iOS open source:
* https://github.com/hoteltonight/HTAutocompleteTextField
* https://github.com/hoteltonight/HTRasterView
* https://github.com/hoteltonight/HTKit
* https://github.com/hoteltonight/HTGradientEasing
* https://github.com/hoteltonight/HTDelegateProxy
* https://github.com/hoteltonight/HTCoreImage
