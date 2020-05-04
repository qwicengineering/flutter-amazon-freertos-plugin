part of flutter_amazon_freertos_plugin;

int decodeToInt(List data, {int bytes = 1}) {
    if (data == null || data.isEmpty) { return 0; }
    Int8List input = Int8List.fromList(data);
    ByteData bd = input.buffer.asByteData();
    switch(bytes) {
        case 2: {
            print("Byte stream converted to int16: ${bd.getInt16(bd.offsetInBytes, Endian.little)}");
            return bd.getUint16(bd.offsetInBytes, Endian.little);
        }            
        case 4: {
            print("Byte stream converted to int16: ${bd.getInt32(bd.offsetInBytes, Endian.little)}");
            return bd.getUint32(bd.offsetInBytes, Endian.little);
        }            
        default: {
            print("Byte stream converted to int8: ${bd.getInt8(bd.offsetInBytes)}");
            return bd.getUint8(bd.offsetInBytes);
        }            
    }
}

String decodeToString(List data) {
    if (data.isEmpty) { return ""; }
    print("Byte stream converted to String: ${utf8.decode(data)}");
    return utf8.decode(data);
}
