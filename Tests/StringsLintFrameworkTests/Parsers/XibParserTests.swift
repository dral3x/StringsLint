//
//  XibParserTests.swift
//  StringsLintFrameworkTests
//
//  Created by Alessandro "Sandro" Calzavara on 23/09/2018.
//

import XCTest
@testable import StringsLintFramework

class XibParserTests: ParserTestCase {

    func testParseSingleString() throws {
        
        let content = """
<userDefinedRuntimeAttribute type="string" keyPath="textLocalized" value="abc"/>
"""
        
        let file = try self.createTempFile("test1.xib", with: content)
        
        let parser = XibParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results[0].key, "abc")
        XCTAssertEqual(results[0].table, "Localizable")
        XCTAssertEqual(results[0].locale, .none)
        XCTAssertEqual(results[0].location, Location(file: file, line: 1))
    }
    
    func testParseExampleFile() throws {
        
        let content = """
<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.XIB" version="3.0" toolsVersion="14313.18" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES">
    <device id="retina4_7" orientation="portrait">
        <adaptation id="fullscreen"/>
    </device>
    <dependencies>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="14283.14"/>
        <capability name="Safe area layout guides" minToolsVersion="9.0"/>
        <capability name="documents saved in the Xcode 8 format" minToolsVersion="8.0"/>
    </dependencies>
    <objects>
        <placeholder placeholderIdentifier="IBFilesOwner" id="-1" userLabel="File's Owner"/>
        <placeholder placeholderIdentifier="IBFirstResponder" id="-2" customClass="UIResponder"/>
        <view contentMode="scaleToFill" id="iN0-l3-epB">
            <rect key="frame" x="0.0" y="0.0" width="375" height="667"/>
            <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
            <subviews>
                <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Label" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="bG1-a1-JBn">
                    <rect key="frame" x="50" y="70" width="275" height="21"/>
                    <fontDescription key="fontDescription" type="system" pointSize="17"/>
                    <nil key="textColor"/>
                    <nil key="highlightedColor"/>
                    <userDefinedRuntimeAttributes>
                        <userDefinedRuntimeAttribute type="string" keyPath="textLocalized" value="text_1"/>
                    </userDefinedRuntimeAttributes>
                </label>
                <label opaque="NO" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="251" text="Label" textAlignment="natural" lineBreakMode="tailTruncation" baselineAdjustment="alignBaselines" adjustsFontSizeToFit="NO" translatesAutoresizingMaskIntoConstraints="NO" id="ZwJ-Hw-pVC">
                    <rect key="frame" x="50" y="141" width="275" height="21"/>
                    <fontDescription key="fontDescription" type="system" pointSize="17"/>
                    <nil key="textColor"/>
                    <nil key="highlightedColor"/>
                    <userDefinedRuntimeAttributes>
                        <userDefinedRuntimeAttribute type="string" keyPath="textLocalized" value="text_2"/>
                    </userDefinedRuntimeAttributes>
                </label>
                <button opaque="NO" contentMode="scaleToFill" contentHorizontalAlignment="center" contentVerticalAlignment="center" buttonType="roundedRect" lineBreakMode="middleTruncation" translatesAutoresizingMaskIntoConstraints="NO" id="ehC-9i-6RA">
                    <rect key="frame" x="50" y="212" width="275" height="30"/>
                    <state key="normal" title="Button"/>
                    <userDefinedRuntimeAttributes>
                        <userDefinedRuntimeAttribute type="string" keyPath="textLocalized" value="text_3"/>
                    </userDefinedRuntimeAttributes>
                </button>
            </subviews>
            <color key="backgroundColor" red="1" green="1" blue="1" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
            <constraints>
                <constraint firstItem="ehC-9i-6RA" firstAttribute="leading" secondItem="vUN-kp-3ea" secondAttribute="leading" constant="50" id="E5F-x2-7kA"/>
                <constraint firstItem="ZwJ-Hw-pVC" firstAttribute="leading" secondItem="vUN-kp-3ea" secondAttribute="leading" constant="50" id="GWK-s4-G0X"/>
                <constraint firstItem="bG1-a1-JBn" firstAttribute="leading" secondItem="vUN-kp-3ea" secondAttribute="leading" constant="50" id="Md8-ef-tta"/>
                <constraint firstItem="ZwJ-Hw-pVC" firstAttribute="top" secondItem="bG1-a1-JBn" secondAttribute="bottom" constant="50" id="P7J-Jr-w8w"/>
                <constraint firstItem="bG1-a1-JBn" firstAttribute="top" secondItem="vUN-kp-3ea" secondAttribute="top" constant="50" id="UIG-0e-1iZ"/>
                <constraint firstItem="vUN-kp-3ea" firstAttribute="trailing" secondItem="ZwJ-Hw-pVC" secondAttribute="trailing" constant="50" id="V49-wh-hP3"/>
                <constraint firstItem="vUN-kp-3ea" firstAttribute="trailing" secondItem="bG1-a1-JBn" secondAttribute="trailing" constant="50" id="jAp-4C-N4f"/>
                <constraint firstItem="ehC-9i-6RA" firstAttribute="top" secondItem="ZwJ-Hw-pVC" secondAttribute="bottom" constant="50" id="phY-XF-Gp5"/>
                <constraint firstItem="vUN-kp-3ea" firstAttribute="trailing" secondItem="ehC-9i-6RA" secondAttribute="trailing" constant="50" id="y7Y-nX-37v"/>
            </constraints>
            <viewLayoutGuide key="safeArea" id="vUN-kp-3ea"/>
        </view>
    </objects>
</document>
"""
        let file = try self.createTempFile("test2.xib", with: content)
        
        let parser = XibParser()
        let results = try parser.parse(file: file)
        
        XCTAssertEqual(results.count, 3)
        
        XCTAssertEqual(results[0].key, "text_1")
        XCTAssertEqual(results[0].table, "Localizable")
        XCTAssertEqual(results[0].locale, .none)
        XCTAssertEqual(results[0].location, Location(file: file, line: 24))
        
        XCTAssertEqual(results[1].key, "text_2")
        XCTAssertEqual(results[1].table, "Localizable")
        XCTAssertEqual(results[1].locale, .none)
        XCTAssertEqual(results[1].location, Location(file: file, line: 33))
        
        XCTAssertEqual(results[2].key, "text_3")
        XCTAssertEqual(results[2].table, "Localizable")
        XCTAssertEqual(results[2].locale, .none)
        XCTAssertEqual(results[2].location, Location(file: file, line: 40))
    }

}
