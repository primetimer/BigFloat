# PrimeFactors

<!---
[![CI Status](http://img.shields.io/travis/primetimer/PrimeFactors.svg?style=flat)](https://travis-ci.org/primetimer/PrimeFactors)
[![Version](https://img.shields.io/cocoapods/v/PrimeFactors.svg?style=flat)](http://cocoapods.org/pods/PrimeFactors)
[![License](https://img.shields.io/cocoapods/l/PrimeFactors.svg?style=flat)](http://cocoapods.org/pods/PrimeFactors)
[![Platform](https://img.shields.io/cocoapods/p/PrimeFactors.svg?style=flat)](http://cocoapods.org/pods/PrimeFactors)
--->

## Example

<!---
To run the example project, clone the repo, and run `pod install` from the Example directory first.
--->
To run the example project, clone the repo, and open the workspace from the Example directory.

## Requirements

Uses the BigInt Pod from https://github.com/attaswift/BigInt 

## Installation

You can use PrimeFactors in your own Application through [CocoaPods](http://cocoapods.org).
To install it,  add the following line to your Podfile:

pod 'PrimeFactors', :git => 'https://github.com/primetimer/PrimeFactors'

Warning: This is a experimental framework for recreational programming. So there is no guarantee the API will stay constant.
Full Refactorings are possible.

This is an example for the Integration in a AnotherApp:

	use_frameworks!
	target 'AnotherApp' do
	pod 'PrimeFactors', :git => 'https://github.com/primetimer/PrimeFactors'
	pod 'BigInt', '~> 3.0'
	pod 'SipHash', '~>1.2'

	target 'AnotherAppTests' do
		inherit! :search_paths
		end
	end


## Author

primetimer, primetimertime@gmail.coom already known as esjot

## License

PrimeFactors is available under the MIT license. See the LICENSE file for more info.
