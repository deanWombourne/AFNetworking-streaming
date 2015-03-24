# AFNetworking+streaming CHANGELOG

### 0.6.1, 0.6.2
Test with AFNetworking 2.5.1
Try to fix warnings with 0.36 cocoapods by using <> instead of ""

## 0.6.0
Added changes from https://github.com/ittna - fix for typos and added a null parser if you _only_ want to parse
chunked responses. The default behaviour is still the same as AFNetworking - see the demo project for an example.

Use SBJSon4 pod instead of SBJson - this will let projects that still use SBJson 3 work with this library.

## 0.5.0
Fix for using the original and new methods on the same session manager object.

## 0.4.0
Now with added JSON item parsing (and framework for adding your own custom item parsing)

## 0.2.0
First real release that parses a stream

## 0.1.0
Initial release.
