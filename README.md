# Kinvey ConfReg

This is a Kinvey sample app to collect attendee data at a conference, to use make an account on
https://console.kinvey.com

This app presents users a form to collect basic biographical information and save it to a collection in your Kinvey backend. 

![](https://github.com/KinveyApps/KinveyConfReg/raw/master/ConfReg_screenshot_thumb.png)

To use, you'll have to create a a new app, and update "app-key" and "app-secret" in the file ConfRegAppDelegate.m
to your app-key and app-secret from the Kinvey console.
See https://console.kinvey.com/#docs/iOS/iOS-Quickstart-Tutorial for more information.

For the best experience, you will need to pre-populate the following data in the console:

* Collections (sample data in the `Sample Data` folder)
 * Industries (can import from `Industries.csv`)
 * Job-Roles (can import from `jobroles.csv`)
* Blob
 * header.png (header image, 1024 x 72)
 * body.png (background image, 1024 x 672)

This sample application is designed for iOS 5+, and uses storyboards and ARC. 

This Application is licensed under Apache License 2.0.


