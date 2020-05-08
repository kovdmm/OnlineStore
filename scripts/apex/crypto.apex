String saltValue = 'password';
String secretKeyValue = 'secret';
String algorithmName = 'HmacSHA256';
Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(saltValue), Blob.valueOf(secretKeyValue));
System.debug(EncodingUtil.base64Encode(hmacData));

System.debug(EncodingUtil.base64Encode(Crypto.generateDigest('SHA256', Blob.valueOf('password'))));

System.debug(EncodingUtil.base64Encode(Crypto.generateDigest('SHA256', Blob.valueOf(String.valueOf(Crypto.getRandomInteger())))));
