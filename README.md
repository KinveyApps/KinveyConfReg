# Kinvey ConfReg

This is a Kinvey sample app to collect attendee data at a conference, to use make an account on
https://console.kinvey.com

This app presents users a form to collect basic biographical information and save it to a collection in your Kinvey backend. 

![](https://github.com/KinveyApps/KinveyConfReg/raw/master/ConfReg_screenshot_thumb.png)

To use, you'll have to create a a new app, and update "app-key" and "app-secret" in the file ConfRegAppDelegate.m
to your app-key and app-secret from the Kinvey console.
See http://devcenter.kinvey.com/ios/guides/getting-started# for more information.

For the best experience, you will need to pre-populate the following data in the console (For populating "Industry" and "Job Role" data in the console using csv files, you will need to import those files using Import functionality present in Data-> Settings-> Import) :

* Collections (sample data in the `Sample Data` folder)
 * Industries (can import from `Industries.csv`)
 * Job-Roles (can import from `jobroles.csv`)
* Blob
 * header.png (header image, 1024 x 72)
 * body.png (background image, 1024 x 672)

This sample application is designed for iOS 5+, and uses storyboards and ARC. 

## License

Copyright (c) 2013 Kinvey, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

