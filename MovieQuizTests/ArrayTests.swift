//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Julia Romanenko on 31.10.2022.
//

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        //Get
        let array = [1,1,2,3,5]
        
        //Whet
        let value = array[safe: 2]
        
        //Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        //Get
        let array = [1,1,2,3,5]
        
        //Whet
        let value = array[safe: 20]
        
        //Then
        XCTAssertNil(value)
    }
}
