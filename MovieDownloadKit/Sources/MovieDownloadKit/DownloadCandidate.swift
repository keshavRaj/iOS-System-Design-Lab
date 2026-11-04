//
//  DownloadCandidate.swift
//  MovieDownloadKit
//
//  Created by Keshav Raj on 02/11/26.
//

public struct DownloadCandidate: Sendable {
    public let id: Int
    public let sizeInBytes: Int64
    public let priority: Int
    
    public init(id: Int, sizeInBytes: Int64, priority: Int) {
        self.id = id
        self.sizeInBytes = sizeInBytes
        self.priority = priority
    }    
}
