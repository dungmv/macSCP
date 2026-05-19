//
//  MockS3Session.swift
//  macSCPTests
//
//  Mock implementation of S3SessionProtocol for testing
//

import Foundation
@testable import macSCP

actor MockS3Session: S3SessionProtocol {
    private(set) var isConnected = false
    private(set) var currentPath = "/"
    private(set) var bucketName = "test-bucket"

    var connectCalled = false
    var disconnectCalled = false
    var listFilesCalled = false
    var getFileInfoCalled = false
    var createDirectoryCalled = false
    var createFileCalled = false
    var deleteFileCalled = false
    var deleteDirectoryCalled = false
    var renameCalled = false
    var copyFileCalled = false
    var copyDirectoryCalled = false
    var moveCalled = false
    var downloadFileCalled = false
    var uploadFileCalled = false
    var readFileContentCalled = false
    var writeFileContentCalled = false
    var getRealPathCalled = false
    var publicURLCalled = false
    var presignedURLCalled = false

    var mockFiles: [RemoteFile] = []
    var mockFileInfo: RemoteFile?
    var mockFileContent = ""
    var mockRealPath = "/"
    var mockPublicURL = URL(string: "https://example.com/test.txt")!
    var mockPresignedURL = URL(string: "https://example.com/test.txt?X-Amz-Signature=test")!
    var lastPresignedExpiration: TimeInterval?
    var lastPublicURLPath: String?
    var lastPresignedURLPath: String?
    var mockError: Error?

    func connect(
        accessKeyId: String,
        secretAccessKey: String,
        region: String,
        bucket: String,
        endpoint: String?
    ) async throws {
        connectCalled = true
        if let mockError { throw mockError }
        bucketName = bucket
        isConnected = true
        currentPath = mockRealPath
    }

    func disconnect() async {
        disconnectCalled = true
        isConnected = false
        currentPath = "/"
        bucketName = ""
    }

    func listFiles(at path: String) async throws -> [RemoteFile] {
        listFilesCalled = true
        if let mockError { throw mockError }
        currentPath = path
        return mockFiles
    }

    func getFileInfo(at path: String) async throws -> RemoteFile {
        getFileInfoCalled = true
        if let mockError { throw mockError }
        guard let mockFileInfo else { throw AppError.fileNotFound }
        return mockFileInfo
    }

    func createDirectory(at path: String) async throws {
        createDirectoryCalled = true
        if let mockError { throw mockError }
    }

    func createFile(at path: String) async throws {
        createFileCalled = true
        if let mockError { throw mockError }
    }

    func deleteFile(at path: String) async throws {
        deleteFileCalled = true
        if let mockError { throw mockError }
    }

    func deleteDirectory(at path: String) async throws {
        deleteDirectoryCalled = true
        if let mockError { throw mockError }
    }

    func rename(from sourcePath: String, to destinationPath: String) async throws {
        renameCalled = true
        if let mockError { throw mockError }
    }

    func copyFile(from sourcePath: String, to destinationPath: String) async throws {
        copyFileCalled = true
        if let mockError { throw mockError }
    }

    func copyDirectory(from sourcePath: String, to destinationPath: String) async throws {
        copyDirectoryCalled = true
        if let mockError { throw mockError }
    }

    func move(from sourcePath: String, to destinationPath: String) async throws {
        moveCalled = true
        if let mockError { throw mockError }
    }

    func downloadFile(from remotePath: String, to localURL: URL) async throws {
        downloadFileCalled = true
        if let mockError { throw mockError }
    }

    func downloadFile(from remotePath: String, to localURL: URL, progress: TransferProgressHandler?) async throws {
        downloadFileCalled = true
        if let mockError { throw mockError }
    }

    func uploadFile(from localURL: URL, to remotePath: String) async throws {
        uploadFileCalled = true
        if let mockError { throw mockError }
    }

    func uploadFile(from localURL: URL, to remotePath: String, progress: TransferProgressHandler?) async throws {
        uploadFileCalled = true
        if let mockError { throw mockError }
    }

    func readFileContent(at path: String) async throws -> String {
        readFileContentCalled = true
        if let mockError { throw mockError }
        return mockFileContent
    }

    func writeFileContent(_ content: String, to path: String) async throws {
        writeFileContentCalled = true
        if let mockError { throw mockError }
    }

    func getRealPath(at path: String) async throws -> String {
        getRealPathCalled = true
        if let mockError { throw mockError }
        return mockRealPath
    }

    func publicURL(for path: String) async throws -> URL {
        publicURLCalled = true
        lastPublicURLPath = path
        if let mockError { throw mockError }
        return mockPublicURL
    }

    func presignedURL(for path: String, expiresIn: TimeInterval) async throws -> URL {
        presignedURLCalled = true
        lastPresignedURLPath = path
        lastPresignedExpiration = expiresIn
        if let mockError { throw mockError }
        return mockPresignedURL
    }
}
