//
//  Data+Extensions.swift
//  LGHTTPRequest
//
//  Created by 龚杰洪 on 2018/3/20.
//  Copyright © 2018年 龚杰洪. All rights reserved.
//

import Foundation
import CCommonCrypto

extension Data {
    
    /// 返回当前Data的MD5值
    ///
    /// - Returns: 当前Data的MD5或nil
    public func md5Hash() -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        
        let hash = self.withUnsafeBytes { (bytes: UnsafePointer<Data>) -> [UInt8] in
            var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes, CC_LONG(self.count), &hash)
            return hash
        }
        
        return (0..<length).map { String(format: "%02x", hash[$0]) }.joined()
    }
    
    /// 通过key对当前Data进行AES加密，key长度必须为32个字符，前16个字符为实际加密key，后16个字符为IV，填充模式PKCS7，块模式CBC
    ///
    /// - Parameter key: 加密key
    /// - Returns: 加密后的data，一般配合base64使用
    /// - Throws: 整个过程中出现的异常
    public func aesEncrypt(with key: String) throws -> Data {
        guard key.length == 32 else {
            throw LGEncryptorError.invalidKey
        }

        let encryptor = LGEncryptor(algorithm: LGEncryptorAlgorithm.aes_128,
                                    options: CCOptions(kCCOptionPKCS7Padding | kCCModeCBC),
                                    iv: key.substring(fromIndex: 16),
                                    ivEncoding: String.Encoding.utf8)
        return try encryptor.crypt(data: self, key: key.substring(toIndex: 16))
    }
}


