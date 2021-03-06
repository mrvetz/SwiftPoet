//
//  PoetFileTest.swift
//  SwiftPoetTests
//
//  Created by Eugene Kazaev on 24/04/2018.
//  Copyright © 2018 Gilt Groupe. All rights reserved.
//

import XCTest
import SwiftPoet

class PoetFileTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHeaderWithNoDate() {
        let cb = ClassSpec.builder(for: "TopLevelClass")
        
        let classSpec = cb.build()
        
        let poetFile = PoetFile(spec: classSpec, generatorInfo: nil, addGenerationDate: false)
        let result = """
        //
        //  TopLevelClass.swift
        //
        //  Contains:
        //  class TopLevelClass
        //
        //  Generated by SwiftPoet
        //

        class TopLevelClass {
        
        }

        """

        XCTAssertEqual(result, poetFile.fileContents)
    }
}
